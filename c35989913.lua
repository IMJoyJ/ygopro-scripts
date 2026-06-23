--永遠の絆
-- 效果：
-- 这个卡名在规则上也当作「超量」卡使用。这个卡名的卡在1回合只能发动1张。
-- ①：作为这张卡的发动时的效果处理，可以从自己墓地把1只「No.39 希望皇 霍普」特殊召唤。那只怪兽的攻击力上升自己墓地的光属性「霍普」超量怪兽的攻击力的合计数值。
-- ②：原本属性是光属性的自己的「霍普」超量怪兽的攻击破坏对方怪兽时才能发动。那只自己怪兽的攻击力下降1000，那只怪兽可以继续攻击。
local s,id,o=GetID()
-- 创建卡片效果，注册发动和攻击效果
function s.initial_effect(c)
	-- 将卡名记录为「No.39 希望皇 霍普」，用于规则判定
	aux.AddCodeList(c,84013237)
	-- 效果①：作为发动时的效果处理，可以从自己墓地把1只「No.39 希望皇 霍普」特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 效果②：原本属性是光属性的自己的「霍普」超量怪兽的攻击破坏对方怪兽时才能发动
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"继续攻击"
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.atkcon)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
end
-- 过滤满足条件的「No.39 希望皇 霍普」怪兽，用于特殊召唤
function s.spfilter(c,e,sp)
	return c:IsCode(84013237) and c:IsCanBeSpecialSummoned(e,0,sp,false,false)
end
-- 过滤满足条件的光属性「霍普」超量怪兽，用于计算攻击力加成
function s.atkfilter(c)
	return c:IsSetCard(0x7f) and c:IsType(TYPE_XYZ) and c:IsAttribute(ATTRIBUTE_LIGHT)
end
-- 发动效果①的处理流程，检索并特殊召唤「No.39 希望皇 霍普」，并根据墓地光属性「霍普」超量怪兽的攻击力合计值提升其攻击力
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取满足条件的「No.39 希望皇 霍普」怪兽组，用于特殊召唤
	local cg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,nil,e,tp)
	-- 判断是否有满足条件的怪兽且场上存在空位
	if #cg>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 询问玩家是否发动特殊召唤
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否特殊召唤？"
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=cg:Select(tp,1,1,nil)
		local tc=sg:GetFirst()
		-- 执行特殊召唤步骤
		if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
			-- 获取满足条件的光属性「霍普」超量怪兽组，用于计算攻击力加成
			local ag=Duel.GetMatchingGroup(s.atkfilter,tp,LOCATION_GRAVE,0,nil)
			local atk=ag:GetSum(Card.GetAttack)
			-- 为特殊召唤的怪兽设置攻击力提升效果
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(atk)
			tc:RegisterEffect(e1)
		end
		-- 完成特殊召唤流程
		Duel.SpecialSummonComplete()
	end
end
-- 判断是否满足效果②发动条件，即攻击怪兽为光属性且为「霍普」超量怪兽且攻击力不低于1000
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local rc=eg:GetFirst()
	-- 判断攻击怪兽是否为当前攻击怪兽且处于对方战斗阶段且正面表示
	return rc==Duel.GetAttacker() and rc:IsStatus(STATUS_OPPO_BATTLE) and rc:IsFaceup()
		and rc:IsSetCard(0x7f) and rc:IsType(TYPE_XYZ)
		and rc:IsAttackAbove(1000) and rc:IsControler(tp)
		and (rc:GetOriginalAttribute()&ATTRIBUTE_LIGHT)~=0
		and not rc:IsStatus(STATUS_DESTROY_CONFIRMED)
end
-- 执行效果②的处理流程，使攻击怪兽攻击力下降1000并可继续攻击
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前攻击怪兽
	local tc=Duel.GetAttacker()
	if tc:IsFaceup() and tc:IsControler(tp) and tc:IsType(TYPE_MONSTER) then
		-- 为攻击怪兽设置攻击力下降1000的效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		if not tc:IsHasEffect(EFFECT_REVERSE_UPDATE) then
			-- 使攻击怪兽可以继续攻击
			Duel.ChainAttack()
		end
	end
end
