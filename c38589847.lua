--アドバンス・フォース
-- 效果：
-- 只要这张卡在场上存在，7星以上的怪兽可以把1只5星以上的怪兽解放作上级召唤。
function c38589847.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 只要这张卡在场上存在，7星以上的怪兽可以把1只5星以上的怪兽解放作上级召唤。
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
-- 筛选可作为解放材料的候选怪兽：必须是5星以上，且是自己场上任意表示形式或对方场上表侧表示的怪兽。
function c38589847.otfilter(c,tp)
	return c:IsLevelAbove(5) and (c:IsControler(tp) or c:IsFaceup())
end
-- 召唤规则条件：若未指定要召唤的怪兽则返回true以允许显示；否则取该怪兽的控制者tp，检索符合条件的祭品候选组，并确认所需解放数不超过1且确实能用1只祭品完成上级召唤。
function c38589847.otcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取双方场上所有满足otfilter条件的怪兽作为祭品候选组，用于解放上级召唤的判定。
	local mg=Duel.GetMatchingGroup(c38589847.otfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 返回条件：所需解放数不超过1，且通过Duel.CheckTribute确认可以从候选组中选出1只祭品完成上级召唤。
	return minc<=1 and Duel.CheckTribute(c,1,1,mg)
end
-- 应用此召唤规则的怪兽必须是7星以上。
function c38589847.ottg(e,c)
	return c:IsLevelAbove(7)
end
-- 执行上级召唤操作：重新获取祭品候选组；若己方主要怪兽区没有空位，则只选择自己场上的怪兽；由玩家选择1只祭品，将其设为召唤素材并解放，完成上级召唤。
function c38589847.otop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 获取当前所有可作为祭品的怪兽组（己方全场及对方场上，满足otfilter），用于实际解放时的选择。
	local mg=Duel.GetMatchingGroup(c38589847.otfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 如果己方主要怪兽区可用空格数小于等于0，则限制祭品只能从自己场上的怪兽中选择。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then
		mg=mg:Filter(Card.IsControler,nil,tp)
	end
	-- 从祭品候选组中由玩家选择1只怪兽作为上级召唤的祭品。
	local sg=Duel.SelectTribute(tp,c,1,1,mg)
	c:SetMaterial(sg)
	-- 解放所选择的祭品，解放原因包含上级召唤和作为召唤素材。
	Duel.Release(sg,REASON_SUMMON+REASON_MATERIAL)
end
