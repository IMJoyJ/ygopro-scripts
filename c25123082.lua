--ヒュグロの魔導書
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己场上1只魔法师族怪兽为对象才能发动。这个回合，那只怪兽的攻击力上升1000，以下效果适用。
-- ●那只怪兽战斗破坏对方怪兽时才能发动。从卡组把1张「魔导书」魔法卡加入手卡。
function c25123082.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以自己场上1只魔法师族怪兽为对象才能发动。这个回合，那只怪兽的攻击力上升1000，以下效果适用。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,25123082+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c25123082.target)
	e1:SetOperation(c25123082.activate)
	c:RegisterEffect(e1)
end
-- 用于筛选自己场上表侧表示的魔法师族怪兽，作为可选择的发动对象。
function c25123082.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_SPELLCASTER)
end
-- 指定发动时的对象：要求选择自己场上1只表侧表示的魔法师族怪兽。
function c25123082.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c25123082.filter(chkc) end
	-- 发动合法性检查：确认自己场上存在1只符合条件的表侧表示魔法师族怪兽可供选择。
	if chk==0 then return Duel.IsExistingTarget(c25123082.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向操作玩家发送选择表侧表示怪兽的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从自己场上选择1只表侧表示的魔法师族怪兽作为效果的对象，并登记为连锁对象。
	Duel.SelectTarget(tp,c25123082.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理：若对象怪兽仍与效果相关且表侧表示、不免疫此效果，则使其攻击力上升1000，并为其附加“战斗破坏对方怪兽时从卡组检索魔导书魔法卡”的效果及相应标记机制。
function c25123082.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and not tc:IsImmuneToEffect(e) then
		-- 这个回合，那只怪兽的攻击力上升1000
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(1000)
		tc:RegisterEffect(e1)
		-- ●那只怪兽战斗破坏对方怪兽时才能发动。从卡组把1张「魔导书」魔法卡加入手卡。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetDescription(aux.Stringid(25123082,0))  --"检索"
		e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
		e2:SetCode(EVENT_BATTLE_DESTROYING)
		e2:SetLabelObject(tc)
		e2:SetCondition(c25123082.shcon)
		e2:SetTarget(c25123082.shtg)
		e2:SetOperation(c25123082.shop)
		e2:SetReset(RESET_PHASE+PHASE_END)
		-- 将“战斗破坏时检索”的效果作为持续效果注册到当前玩家，由该效果监视战斗破坏事件。
		Duel.RegisterEffect(e2,tp)
		-- 那只怪兽战斗破坏对方怪兽时
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EFFECT_DESTROY_REPLACE)
		e3:SetRange(LOCATION_MZONE)
		e3:SetCondition(c25123082.regcon)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e3)
	end
end
-- 战斗破坏标记注册：当带有本效果的怪兽战斗破坏对方怪兽时，为自身标记一个战斗破坏记号，用于确认该怪兽确实发生过战斗破坏。
function c25123082.regcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:GetBattleTarget() and r==REASON_BATTLE then
		c:RegisterFlagEffect(25123082,RESET_PHASE+PHASE_DAMAGE,0,1)
	end
	return false
end
-- 检索效果的发动条件：确认触发战斗破坏事件的是被赋予检索效果的对象怪兽，且该怪兽带有战斗破坏标记。
function c25123082.shcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	return eg:IsContains(tc) and tc:GetFlagEffect(25123082)~=0
end
-- 检索筛选条件：卡名属于“魔导书”字段、是魔法卡且能够加入手卡。
function c25123082.shfilter(c)
	return c:IsSetCard(0x106e) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- 检索效果的发动条件检查：确认卡组中是否有符合条件的“魔导书”魔法卡，并设定检索的操作信息。
function c25123082.shtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检索效果发动时检查卡组中是否存在至少1张符合条件的“魔导书”魔法卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c25123082.shfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记效果处理时将进行“从卡组把1张卡加入手卡”的操作信息，以供卡组检索类效果检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果处理：从卡组选择1张符合条件的“魔导书”魔法卡加入手卡，并让对方确认。
function c25123082.shop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手卡的卡牌。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张符合条件的“魔导书”魔法卡。
	local g=Duel.SelectMatchingCard(tp,c25123082.shfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入持有者的手卡（检索到手牌）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的那张卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
