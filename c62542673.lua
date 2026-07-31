--D－HERO デビルロードガイ
local s,id,o=GetID()
-- 初始化卡片效果：注册记述卡片、召·特召成功暂时除外对方怪兽效果、以及卡组堆墓检索指定卡效果
function s.initial_effect(c)
	-- 注册卡片记述列表：记录卡号为75041269和4663194的卡片
	aux.AddCodeList(c,75041269,4663194)
	-- ①：这张卡召唤·特殊召唤成功的场合，以对方场上1只怪兽为对象才能发动。那只怪兽暂时除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.rmtg)
	e1:SetOperation(s.rmop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：自己主要阶段才能发动。从卡组把1只「D-HERO」怪兽送去墓地，从卡组·墓地把1张指定卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetCost(s.thcost)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
-- 除外目标过滤条件：可以除外的卡
function s.rmfilter(c)
	return c:IsAbleToRemove()
end
-- ①效果发动准备：选择对方场上1只怪兽为对象
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.rmfilter(chkc) and chkc:IsControler(1-tp) end
	-- 发动条件检查：对方场上是否存在可以除外的怪兽
	if chk==0 then return Duel.IsExistingTarget(s.rmfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方场上1只怪兽作为对象
	local g=Duel.SelectTarget(tp,s.rmfilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁操作信息：除外选中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- ①效果处理：暂时除外目标怪兽，并注册下个准备阶段返回场上的延迟效果
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果对象卡片
	local tc=Duel.GetFirstTarget()
	-- 检查对象合法性并将目标怪兽暂时除外
	if tc:IsRelateToChain() and tc:IsType(TYPE_MONSTER) and Duel.Remove(tc,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,2,0,aux.Stringid(id,2))
		-- 那只怪兽直到下个回合的准备阶段除外。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		-- 检查当前是否已处于准备阶段
		if Duel.GetCurrentPhase()==PHASE_STANDBY then
			e1:SetReset(RESET_PHASE+PHASE_STANDBY,2)
		else
			e1:SetReset(RESET_PHASE+PHASE_STANDBY)
		end
		e1:SetLabelObject(tc)
		e1:SetCountLimit(1)
		e1:SetCondition(s.retcon)
		e1:SetOperation(s.retop)
		-- 记录当前回合数
		e1:SetLabel(Duel.GetTurnCount())
		-- 注册在准备阶段触发的全局延迟处理效果
		Duel.RegisterEffect(e1,tp)
	end
end
-- 怪兽返回条件检查：到达非当回合的准备阶段且Flag标记存在
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 检查是否已跨越回合且目标卡标记有效
	return Duel.GetTurnCount()~=e:GetLabel() and tc:GetFlagEffect(id)~=0
end
-- 怪兽返回处理：将暂时除外的怪兽返回场上
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 将暂时除外的目标怪兽以原表示形式返回场上
	Duel.ReturnToField(e:GetLabelObject())
end
-- Cost过滤条件：卡组中可送去墓地的「D-HERO」怪兽
function s.tgfilter(c)
	return c:IsSetCard(0xc008) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
-- ②效果发动Cost：从卡组把1只「D-HERO」怪兽送去墓地
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- Cost检查：卡组是否存在可送去墓地的「D-HERO」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组选择1只满足条件的「D-HERO」怪兽
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 将选中的卡送去墓地作为Cost
	Duel.SendtoGrave(g,REASON_COST)
end
-- 检索过滤条件：卡名符合要求的卡且可加入手牌
function s.thfilter(c)
	return c:IsCode(75041269,4663194) and c:IsAbleToHand()
end
-- ②效果发动准备：设置从卡组·墓地检索卡片的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：卡组或墓地是否存在满足条件的检索卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置连锁操作信息：从卡组/墓地检索1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- ②效果处理：从卡组/墓地把指定卡加入手牌，并注册暗属性HERO特召誓约
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组/墓地选择1张满足条件的卡
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
	-- 这个效果的发动后，直到回合结束时自己不是暗属性「HERO」怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 为己方玩家注册本回合特殊召唤限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 特召限制条件：禁止特殊召唤暗属性「HERO」以外的怪兽
function s.splimit(e,c)
	return not (c:IsAttribute(ATTRIBUTE_DARK) and c:IsSetCard(0x8))
end
