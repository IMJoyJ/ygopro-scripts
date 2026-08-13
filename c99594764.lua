--ドラグニティ－コルセスカ
-- 效果：
-- ①：把这张卡当作装备卡使用来装备的怪兽战斗破坏对方怪兽时才能发动。种族·属性和装备怪兽相同的1只4星以下的怪兽从卡组加入手卡。
function c99594764.initial_effect(c)
	-- ①：把这张卡当作装备卡使用来装备的怪兽战斗破坏对方怪兽时才能发动。种族·属性和装备怪兽相同的1只4星以下的怪兽从卡组加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(99594764,0))  --"卡组检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCondition(c99594764.thcon)
	e1:SetTarget(c99594764.thtg)
	e1:SetOperation(c99594764.thop)
	c:RegisterEffect(e1)
end
-- 发动条件：战斗破坏对方怪兽而送去墓地的怪兽只有1只，且该怪兽就是这张卡当前装备的对象（即e:GetHandler():GetEquipTarget()）。
function c99594764.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:GetCount()==1 and eg:GetFirst()==e:GetHandler():GetEquipTarget()
end
-- 检索过滤器：卡组的怪兽必须与装备怪兽持有相同的种族和属性，等级为4星以下，并且可以被加入手卡。
function c99594764.filter(c,race,att)
	return c:IsRace(race) and c:IsAttribute(att) and c:IsLevelBelow(4) and c:IsAbleToHand()
end
-- 发动目标处理：取得装备怪兽eqc，在发动时检查卡组是否存在符合条件的怪兽，并设置本次操作的信息为从卡组加入手卡。
function c99594764.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local eqc=e:GetHandler():GetEquipTarget()
	-- 在卡组区域中检索是否存在至少1张满足指定种族、属性和等级条件的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c99594764.filter,tp,LOCATION_DECK,0,1,nil,eqc:GetRace(),eqc:GetAttribute()) end
	-- 设定操作信息：本次效果分类为加入手卡（CATEGORY_TOHAND），计划从卡组将1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理执行：取得装备怪兽，若不存在则终止；提示玩家选择要加入手卡的卡，然后从卡组选择符合条件的1张怪兽，加入手牌并让对手确认。
function c99594764.thop(e,tp,eg,ep,ev,re,r,rp)
	local eqc=e:GetHandler():GetEquipTarget()
	if not eqc then return end
	-- 发送选择提示：给玩家显示“请选择要加入手牌的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从对方的卡组中筛选出1张满足装备怪兽种族、属性和等级4以下条件的怪兽供玩家选择。
	local g=Duel.SelectMatchingCard(tp,c99594764.filter,tp,LOCATION_DECK,0,1,1,nil,eqc:GetRace(),eqc:GetAttribute())
	if g:GetCount()>0 then
		-- 将选择的卡片加入其持有者的手牌，原因记为效果（REASON_EFFECT）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对手（1-tp）确认加入手牌的卡片。
		Duel.ConfirmCards(1-tp,g)
	end
end
