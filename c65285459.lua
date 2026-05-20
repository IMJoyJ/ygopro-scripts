--聖天樹の大精霊
-- 效果：
-- 植物族怪兽2只以上
-- ①：这张卡不会被作为攻击对象（自己场上只有被这个效果适用的怪兽存在的状态中对方的攻击变成对自己的直接攻击）。
-- ②：1回合最多3次，自己因战斗·效果受到伤害的场合才能发动。自己基本分回复那个数值，从额外卡组把1只「圣蔓」怪兽特殊召唤。
-- ③：1回合1次，这所连接区的怪兽成为攻击对象时才能发动。攻击无效，那只自己怪兽的位置向其他的自己的主要怪兽区域移动。
function c65285459.initial_effect(c)
	-- 设置连接召唤的手续，需要2只以上的植物族怪兽作为素材
	aux.AddLinkProcedure(c,c65285459.mfilter,2,99)
	c:EnableReviveLimit()
	-- ①：这张卡不会被作为攻击对象（自己场上只有被这个效果适用的怪兽存在的状态中对方的攻击变成对自己的直接攻击）。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_IGNORE_BATTLE_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ②：1回合最多3次，自己因战斗·效果受到伤害的场合才能发动。自己基本分回复那个数值，从额外卡组把1只「圣蔓」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(65285459,0))  --"回复并特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(3)
	e2:SetCondition(c65285459.spcon)
	e2:SetTarget(c65285459.sptg)
	e2:SetOperation(c65285459.spop)
	c:RegisterEffect(e2)
	-- ③：1回合1次，这所连接区的怪兽成为攻击对象时才能发动。攻击无效，那只自己怪兽的位置向其他的自己的主要怪兽区域移动。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(65285459,1))
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BE_BATTLE_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(c65285459.mvcon)
	e4:SetTarget(c65285459.mvtg)
	e4:SetOperation(c65285459.mvop)
	c:RegisterEffect(e4)
end
-- 过滤连接素材：植物族怪兽
function c65285459.mfilter(c)
	return c:IsLinkRace(RACE_PLANT)
end
-- 效果②的发动条件：自己因战斗或效果受到伤害
function c65285459.spcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and bit.band(r,REASON_BATTLE+REASON_EFFECT)~=0
end
-- 过滤额外卡组中可以特殊召唤的「圣蔓」怪兽
function c65285459.spfilter(c,e,tp)
	-- 检查卡片是否属于「圣蔓」系列、能否特殊召唤，且额外卡组怪兽出场区域有空位
	return c:IsSetCard(0x1158) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 效果②的发动准备与目标确认：检查额外卡组是否有可特召的「圣蔓」怪兽，并设置特殊召唤和回复生命值的操作信息
function c65285459.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查额外卡组是否存在至少1只满足特召条件的「圣蔓」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c65285459.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息，表示将从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- 设置回复生命值的操作信息，数值为受到的伤害值
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,1,tp,ev)
end
-- 效果②的效果处理：自己回复受到的伤害数值的生命值，并从额外卡组特殊召唤1只「圣蔓」怪兽
function c65285459.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 尝试让玩家回复与受到的伤害等量的生命值，若成功回复则继续处理
	if Duel.Recover(tp,ev,REASON_EFFECT)~=0 then
		-- 提示玩家选择要特殊召唤的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 玩家从额外卡组选择1只满足条件的「圣蔓」怪兽
		local g=Duel.SelectMatchingCard(tp,c65285459.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
		if #g>0 then
			-- 将选中的怪兽以表侧表示特殊召唤到自己场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 效果③的发动条件：自己场上此卡所连接区的怪兽被选为攻击对象
function c65285459.mvcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的攻击对象（被攻击的怪兽）
	local d=Duel.GetAttackTarget()
	return d and d:IsControler(tp) and e:GetHandler():GetLinkedGroup():IsContains(d)
end
-- 效果③的发动准备与目标确认：检查自己场上是否有可用的主要怪兽区域空格
function c65285459.mvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的主要怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0)>0 end
end
-- 效果③的效果处理：无效攻击，并将被攻击的怪兽移动到其他的自己主要怪兽区域
function c65285459.mvop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被攻击的怪兽
	local tc=Duel.GetAttackTarget()
	-- 尝试无效此次攻击，若成功且自己场上仍有可用怪兽区域，则继续处理
	if Duel.NegateAttack() and Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0)>0 then
		-- 提示玩家选择要移动到的怪兽区域
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)  --"请选择要移动到的位置"
		-- 让玩家选择1个自己场上可用的主要怪兽区域
		local s=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,0)
		local nseq=math.log(s,2)
		-- 将被攻击的怪兽移动到选中的怪兽区域
		Duel.MoveSequence(tc,nseq)
	end
end
