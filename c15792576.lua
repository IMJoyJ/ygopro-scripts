--天魔神 シドヘルズ
-- 效果：
-- 这张卡不能特殊召唤。
-- ①：这张卡上级召唤成功的场合才能发动。为这张卡的上级召唤而解放的怪兽的种族·属性的以下效果适用。
-- ●天使族·光属性：从卡组把1只天使族·光属性或者恶魔族·暗属性的怪兽加入手卡。
-- ●恶魔族·暗属性：从卡组把天使族·光属性和恶魔族·暗属性的怪兽各最多1只送去墓地。
function c15792576.initial_effect(c)
	-- 这张卡不能特殊召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e0)
	-- ①：这张卡上级召唤成功的场合才能发动。为这张卡的上级召唤而解放的怪兽的种族·属性的以下效果适用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(15792576,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(c15792576.opcon)
	e1:SetTarget(c15792576.optg)
	e1:SetOperation(c15792576.opop)
	c:RegisterEffect(e1)
	-- ●天使族·光属性：从卡组把1只天使族·光属性或者恶魔族·暗属性的怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(c15792576.valcheck)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
end
-- ●恶魔族·暗属性：从卡组把天使族·光属性和恶魔族·暗属性的怪兽各最多1只送去墓地。
function c15792576.chkfilter(c,rac,att)
	return c:IsRace(rac) and c:IsAttribute(att)
end
-- 创建一个特殊召唤条件效果，使该卡无法被特殊召唤。
function c15792576.valcheck(e,c)
	local label=0
	local g=c:GetMaterial()
	if g:IsExists(c15792576.chkfilter,1,nil,RACE_FAIRY,ATTRIBUTE_LIGHT) then
		label=label+1
	end
	if g:IsExists(c15792576.chkfilter,1,nil,RACE_FIEND,ATTRIBUTE_DARK) then
		label=label+2
	end
	e:GetLabelObject():SetLabel(label)
end
-- 创建一个诱发选发效果，用于处理上级召唤成功后的效果。
function c15792576.opcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE) and e:GetLabel()>0
end
-- 创建一个用于检测上级召唤的条件函数。
function c15792576.thfilter(c)
	return (c:IsRace(RACE_FAIRY) and c:IsAttribute(ATTRIBUTE_LIGHT)) or (c:IsRace(RACE_FIEND) and c:IsAttribute(ATTRIBUTE_DARK)) and c:IsAbleToHand()
end
-- 创建一个用于检索天使族·光属性或恶魔族·暗属性怪兽的过滤函数。
function c15792576.tgfilter(c)
	return (c:IsRace(RACE_FAIRY) and c:IsAttribute(ATTRIBUTE_LIGHT)) or (c:IsRace(RACE_FIEND) and c:IsAttribute(ATTRIBUTE_DARK)) and c:IsAbleToGrave()
end
-- 创建一个用于送去墓地的天使族·光属性或恶魔族·暗属性怪兽的过滤函数。
function c15792576.optg(e,tp,eg,ep,ev,re,r,rp,chk)
	local label=e:GetLabel()
	if chk==0 then
		if label==1 then
			-- 检查卡组中是否存在满足条件的怪兽以加入手牌。
			return Duel.IsExistingMatchingCard(c15792576.thfilter,tp,LOCATION_DECK,0,1,nil)
		elseif label==2 then
			-- 检查卡组中是否存在满足条件的怪兽以送去墓地。
			return Duel.IsExistingMatchingCard(c15792576.tgfilter,tp,LOCATION_DECK,0,1,nil)
		else
			return true
		end
	end
	e:SetLabel(label)
	if label==1 then
		-- 提示对方选择了“卡组检索”效果。
		Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(15792576,1))  --"卡组检索"
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		-- 设置操作信息为将卡加入手牌。
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	elseif label==2 then
		-- 提示对方选择了“送去墓地”效果。
		Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(15792576,2))  --"送去墓地"
		e:SetCategory(CATEGORY_TOGRAVE)
		-- 设置操作信息为将卡送去墓地。
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	end
end
-- 处理效果发动后的实际操作。
function c15792576.opop(e,tp,eg,ep,ev,re,r,rp)
	local label=e:GetLabel()
	if label==1 then
		-- 提示玩家选择要加入手牌的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 选择满足条件的1张卡加入手牌。
		local g1=Duel.SelectMatchingCard(tp,c15792576.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g1:GetCount()>0 then
			-- 将选中的卡加入手牌。
			Duel.SendtoHand(g1,nil,REASON_EFFECT)
			-- 确认对方看到选中的卡。
			Duel.ConfirmCards(1-tp,g1)
		end
	elseif label==2 then
		-- 获取满足条件的卡组。
		local g=Duel.GetMatchingGroup(c15792576.tgfilter,tp,LOCATION_DECK,0,nil)
		-- 提示玩家选择要送去墓地的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 选择满足条件的1至2张卡送去墓地。
		local g2=g:SelectSubGroup(tp,aux.drccheck,false,1,2)
		if g2 then
			-- 将选中的卡送去墓地。
			Duel.SendtoGrave(g2,REASON_EFFECT)
		end
	end
end
