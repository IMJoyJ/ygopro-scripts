--幻影騎士団シェード・ブリガンダイン
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。自己墓地没有陷阱卡存在的场合，这张卡在盖放的回合也能发动。
-- ①：这张卡发动后变成通常怪兽（战士族·暗·4星·攻0/守300）在怪兽区域守备表示特殊召唤（不当作陷阱卡使用）。
function c98827725.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：这张卡发动后变成通常怪兽（战士族·暗·4星·攻0/守300）在怪兽区域守备表示特殊召唤（不当作陷阱卡使用）。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,98827725+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c98827725.target)
	e1:SetOperation(c98827725.activate)
	c:RegisterEffect(e1)
	-- 自己墓地没有陷阱卡存在的场合，这张卡在盖放的回合也能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(98827725,0))  --"适用「幻影骑士团 阴暗布面甲」的效果来发动"
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2:SetCondition(c98827725.actcon)
	c:RegisterEffect(e2)
end
-- 发动时的效果适用性检查，判断是否满足发动条件（怪兽区域有空位且玩家可以特殊召唤该陷阱怪兽）。
function c98827725.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- 检查自己场上的主要怪兽区域是否有空位。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否可以将该卡作为特定属性、种族、等级和攻防的通常怪兽特殊召唤。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,98827725,0x10db,TYPES_NORMAL_TRAP_MONSTER,0,300,4,RACE_WARRIOR,ATTRIBUTE_DARK) end
	-- 设置连锁处理的操作信息，声明此效果包含将自身特殊召唤的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理时，若卡片仍存在且满足特招条件，则赋予其通常怪兽属性并以守备表示特殊召唤到场上。
function c98827725.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 在效果处理时，检查此卡是否仍与该效果相关，且玩家是否仍能特殊召唤该陷阱怪兽。
	if c:IsRelateToEffect(e) and Duel.IsPlayerCanSpecialSummonMonster(tp,98827725,0x10db,TYPES_NORMAL_TRAP_MONSTER,0,300,4,RACE_WARRIOR,ATTRIBUTE_DARK) then
		c:AddMonsterAttribute(TYPE_NORMAL)
		-- 将此卡在自己的怪兽区域以表侧守备表示特殊召唤。
		Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP_DEFENSE)
	end
end
-- 盖放回合发动的条件判断函数，检查自己墓地是否存在陷阱卡。
function c98827725.actcon(e)
	-- 检查自己墓地中是否不存在陷阱卡。
	return not Duel.IsExistingMatchingCard(Card.IsType,e:GetHandlerPlayer(),LOCATION_GRAVE,0,1,nil,TYPE_TRAP)
end
