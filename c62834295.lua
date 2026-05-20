--オルフェゴール・アインザッツ
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：对方对怪兽的召唤·特殊召唤成功的场合才能发动。从手卡·卡组选1只「自奏圣乐」怪兽或者「星遗物」怪兽送去墓地或除外。
function c62834295.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：对方对怪兽的召唤·特殊召唤成功的场合才能发动。从手卡·卡组选1只「自奏圣乐」怪兽或者「星遗物」怪兽送去墓地或除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(62834295,0))
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,62834295)
	e2:SetCondition(c62834295.tgcon)
	e2:SetTarget(c62834295.tgtg)
	e2:SetOperation(c62834295.tgop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 过滤函数：检查怪兽的召唤玩家是否为指定玩家
function c62834295.cfilter(c,tp)
	return c:IsSummonPlayer(tp)
end
-- 发动条件：对方对怪兽的召唤·特殊召唤成功
function c62834295.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c62834295.cfilter,1,nil,1-tp)
end
-- 过滤函数：手卡·卡组中可以送去墓地或除外的「自奏圣乐」或「星遗物」怪兽
function c62834295.tgfilter(c)
	return c:IsSetCard(0xfe,0x11b) and c:IsType(TYPE_MONSTER) and (c:IsAbleToGrave() or c:IsAbleToRemove())
end
-- 效果发动的准备：检查可行性并设置送去墓地和除外的操作信息
function c62834295.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡·卡组中是否存在至少1只满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c62834295.tgfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：预计从手卡·卡组将1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
	-- 设置操作信息：预计从手卡·卡组将1张卡除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 效果处理：从手卡·卡组选1只符合条件的怪兽，并选择将其送去墓地或除外
function c62834295.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 在客户端显示提示信息，要求玩家选择要送去墓地或除外的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(62834295,1))  --"请选择要送去墓地或除外的怪兽"
	-- 让玩家从手卡·卡组选择1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c62834295.tgfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		local tc=g:GetFirst()
		-- 判断卡片是否只能送去墓地，或者在两者皆可时由玩家选择“送去墓地”
		if tc and tc:IsAbleToGrave() and (not tc:IsAbleToRemove() or Duel.SelectOption(tp,1191,1192)==0) then
			-- 将选中的怪兽因效果送去墓地
			Duel.SendtoGrave(tc,REASON_EFFECT)
		else
			-- 将选中的怪兽因效果表侧表示除外
			Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
		end
	end
end
