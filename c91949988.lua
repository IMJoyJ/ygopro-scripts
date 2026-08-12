--迅雷の騎士ガイアドラグーン
-- 效果：
-- 7星怪兽×2
-- 这张卡也能在自己场上的5·6阶的超量怪兽上面重叠来超量召唤。
-- ①：这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
function c91949988.initial_effect(c)
	aux.AddXyzProcedure(c,nil,7,2,c91949988.ovfilter,aux.Stringid(91949988,0))  --"是否在5·6阶的超量怪兽上面重叠超量召唤？"
	c:EnableReviveLimit()
	-- ①：这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e1)
end
-- 定义重叠超量召唤的素材条件：自己场上表侧表示的5阶或6阶超量怪兽
function c91949988.ovfilter(c)
	return c:IsFaceup() and c:IsRank(5,6)
end
