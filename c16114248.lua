--ペアサイクロイド
-- 效果：
-- 同名机械族怪兽×2
-- ①：这张卡可以直接攻击。
function c16114248.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用2个满足条件的机械族怪兽作为融合素材
	aux.AddFusionProcFunRep(c,c16114248.ffilter,2,true)
	-- ①：这张卡可以直接攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	c:RegisterEffect(e1)
end
-- 定义融合召唤时的过滤条件函数，用于判断哪些怪兽可以作为融合素材
function c16114248.ffilter(c,fc,sub,mg,sg)
	-- 返回值为true表示该怪兽可以作为融合素材，条件是：必须为机械族，并且满足融合素材组中无重复卡号或无融合素材组时
	return c:IsRace(RACE_MACHINE) and (not sg or sg:FilterCount(aux.TRUE,c)==0 or sg:IsExists(Card.IsFusionCode,1,c,c:GetFusionCode()))
end
