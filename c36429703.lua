--RR－ワイズ・ストリクス
-- 效果：
-- 鸟兽族·暗属性怪兽2只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡连接召唤的场合才能发动。从卡组把1只鸟兽族·暗属性·4星怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽不能作为连接素材，效果无效化。
-- ②：自己的「急袭猛禽」超量怪兽的效果发动的场合发动。从卡组把1张「升阶魔法」魔法卡在自己场上盖放。把速攻魔法卡盖放的场合，那张卡在盖放的回合也能发动。
function c36429703.initial_effect(c)
	-- 为卡片添加连接召唤手续，要求使用2~2个满足条件的鸟兽族·暗属性怪兽作为连接素材
	aux.AddLinkProcedure(c,c36429703.matfilter,2,2)
	c:EnableReviveLimit()
	-- ①：这张卡连接召唤的场合才能发动。从卡组把1只鸟兽族·暗属性·4星怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽不能作为连接素材，效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(36429703,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,36429703)
	e1:SetCondition(c36429703.spcon)
	e1:SetTarget(c36429703.sptg)
	e1:SetOperation(c36429703.spop)
	c:RegisterEffect(e1)
	-- ②：自己的「急袭猛禽」超量怪兽的效果发动的场合发动。从卡组把1张「升阶魔法」魔法卡在自己场上盖放。把速攻魔法卡盖放的场合，那张卡在盖放的回合也能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(36429703,1))
	e3:SetCategory(CATEGORY_SSET)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,36429704)
	e3:SetCondition(c36429703.setcon)
	e3:SetOperation(c36429703.setop)
	c:RegisterEffect(e3)
end
-- 连接召唤所用的素材必须满足的条件：为鸟兽族且属性为暗
function c36429703.matfilter(c)
	return c:IsLinkRace(RACE_WINDBEAST) and c:IsLinkAttribute(ATTRIBUTE_DARK)
end
-- 效果发动的条件：此卡为连接召唤方式特殊召唤成功
function c36429703.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 用于检索满足条件的怪兽的过滤函数：4星鸟兽族暗属性怪兽且可守备表示特殊召唤
function c36429703.spfilter(c,e,tp)
	return c:IsLevel(4) and c:IsRace(RACE_WINDBEAST) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果的发动条件判断：检查场上是否有空位且卡组是否存在满足条件的怪兽
function c36429703.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c36429703.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁操作信息：准备特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数：选择并特殊召唤满足条件的怪兽，并附加效果使其不能作为连接素材、效果无效化
function c36429703.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查场上是否有空位，若无则不继续处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c36429703.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 执行特殊召唤操作并附加效果
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
		-- 使特殊召唤的怪兽效果无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 使特殊召唤的怪兽效果无效化
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		-- 使特殊召唤的怪兽不能作为连接素材
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
		e3:SetValue(1)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e3)
	end
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
-- 触发效果的条件：对方发动的超量怪兽效果且为「急袭猛禽」卡组
function c36429703.setcon(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	return re:IsActiveType(TYPE_XYZ) and rc:IsSetCard(0xba) and rc:IsControler(tp)
end
-- 用于检索满足条件的魔法卡的过滤函数：「升阶魔法」魔法卡且可盖放
function c36429703.setfilter(c)
	return c:IsSetCard(0x95) and c:IsType(TYPE_SPELL) and c:IsSSetable()
end
-- 效果处理函数：选择并盖放满足条件的魔法卡，若为速攻魔法则允许在盖放回合发动
function c36429703.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要盖放的魔法卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从卡组选择满足条件的魔法卡
	local g=Duel.SelectMatchingCard(tp,c36429703.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	-- 执行盖放操作并判断是否成功
	if tc and Duel.SSet(tp,tc)~=0 then
		if tc:IsType(TYPE_QUICKPLAY) then
			-- 为速攻魔法卡添加效果：允许在盖放回合发动
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetDescription(aux.Stringid(36429703,2))  --"适用「急袭猛禽-智慧林鸮」的效果来发动"
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
			e1:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
	end
end
