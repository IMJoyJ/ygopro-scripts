--キメラテック・メガフリート・ドラゴン
-- 效果：
-- 「电子龙」怪兽＋额外怪兽区域的怪兽1只以上
-- 把自己·对方场上的上记的卡送去墓地的场合才能从额外卡组特殊召唤。这张卡不能作为融合素材。
-- ①：这张卡的原本攻击力变成作为这张卡的融合素材的怪兽数量×1200。
function c87116928.initial_effect(c)
	c:EnableReviveLimit()
	-- 设定融合素材为1只「电子龙」怪兽以及1只以上额外怪兽区域的怪兽
	aux.AddFusionProcFunFunRep(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x1093),c87116928.matfilter,1,127,true)
	-- 注册接触融合的特殊召唤规则，指定素材在双方怪兽区域并定义素材处理函数
	aux.AddContactFusionProcedure(c,c87116928.cfilter,LOCATION_MZONE,LOCATION_MZONE,c87116928.sprop(c))
	-- 把自己·对方场上的上记的卡送去墓地的场合才能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c87116928.splimit)
	c:RegisterEffect(e1)
	-- 这张卡不能作为融合素材。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end
c87116928.material_setcode=0x1093
-- 过滤位于额外怪兽区域的怪兽（格子序号为5或6）
function c87116928.matfilter(c)
	return c:GetSequence()>4
end
-- 限制该卡从额外卡组的特殊召唤，使其只能通过自身规则特召
function c87116928.splimit(e,se,sp,st)
	return e:GetHandler():GetLocation()~=LOCATION_EXTRA
end
-- 过滤可以作为代价值送去墓地的怪兽（己方场上任意表示，对方场上须表侧表示）
function c87116928.cfilter(c,fc)
	return c:IsAbleToGraveAsCost() and (c:IsControler(fc:GetControler()) or c:IsFaceup())
end
-- 定义特殊召唤时的素材处理：将素材送去墓地，并根据素材数量确定原本攻击力
function c87116928.sprop(c)
	return	function(g)
				-- 将选定的素材怪兽作为代价值送去墓地
				Duel.SendtoGrave(g,REASON_COST)
				-- ①：这张卡的原本攻击力变成作为这张卡的融合素材的怪兽数量×1200。
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_SET_BASE_ATTACK)
				e1:SetReset(RESET_EVENT+0xff0000)
				e1:SetValue(g:GetCount()*1200)
				c:RegisterEffect(e1)
			end
end
