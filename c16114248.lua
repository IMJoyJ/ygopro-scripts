--ペアサイクロイド
-- 效果：
-- 同名机械族怪兽×2
-- ①：这张卡可以直接攻击。
function c16114248.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：需要2只满足ffilter条件（即同名机械族怪兽）的怪兽作为融合素材，使这张卡可以通过融合召唤正规出场并受苏生限制。
	aux.AddFusionProcFunRep(c,c16114248.ffilter,2,true)
	-- ①：这张卡可以直接攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	c:RegisterEffect(e1)
end
-- 定义融合素材筛选函数ffilter：用于判断候选怪兽是否可作为融合素材，要求素材为机械族且若已选择过素材则必须与已选素材同名（通过融合代码判断），以此实现“同名机械族怪兽×2”的融合素材条件。
function c16114248.ffilter(c,fc,sub,mg,sg)
	-- 判断候选素材c是否为机械族；并且：若当前没有已选素材（sg为空），则任意机械族都可作为第一只素材；若已有已选素材，则要求候选素材的融合代码与已选素材中的至少1张相同，即保证两只素材同名。
	return c:IsRace(RACE_MACHINE) and (not sg or sg:FilterCount(aux.TRUE,c)==0 or sg:IsExists(Card.IsFusionCode,1,c,c:GetFusionCode()))
end
