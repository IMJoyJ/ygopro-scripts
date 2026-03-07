--アドバンス・フォース
-- 效果：
-- 只要这张卡在场上存在，7星以上的怪兽可以把1只5星以上的怪兽解放作上级召唤。
function c38589847.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 把1只5星以上的怪兽解放上级召唤
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(38589847,0))  --"把1只5星以上的怪兽解放上级召唤"
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_HAND,0)
	e2:SetCode(EFFECT_SUMMON_PROC)
	e2:SetCondition(c38589847.otcon)
	e2:SetTarget(c38589847.ottg)
	e2:SetOperation(c38589847.otop)
	e2:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_SET_PROC)
	c:RegisterEffect(e3)
end
-- 过滤满足等级5以上且为我方或表侧表示的怪兽
function c38589847.otfilter(c,tp)
	return c:IsLevelAbove(5) and (c:IsControler(tp) or c:IsFaceup())
end
-- 判断是否满足上级召唤的祭品条件
function c38589847.otcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取场上满足条件的怪兽数组
	local mg=Duel.GetMatchingGroup(c38589847.otfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 检查是否能用1只怪兽作为祭品进行召唤
	return minc<=1 and Duel.CheckTribute(c,1,1,mg)
end
-- 判断怪兽等级是否为7以上
function c38589847.ottg(e,c)
	return c:IsLevelAbove(7)
end
-- 处理上级召唤时选择并解放祭品的流程
function c38589847.otop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 获取场上满足条件的怪兽数组
	local mg=Duel.GetMatchingGroup(c38589847.otfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 判断我方怪兽区是否已满
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then
		mg=mg:Filter(Card.IsControler,nil,tp)
	end
	-- 选择1只作为祭品的怪兽
	local sg=Duel.SelectTribute(tp,c,1,1,mg)
	c:SetMaterial(sg)
	-- 解放所选怪兽作为召唤的祭品
	Duel.Release(sg,REASON_SUMMON+REASON_MATERIAL)
end
