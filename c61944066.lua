--Recettes de Nouvellez～ヌーベルズのレシピ帳～
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：只要自己场上有「新式魔厨」怪兽卡存在，对方场上的表侧表示怪兽变成攻击表示。
-- ②：每次仪式怪兽的效果让怪兽被解放，对方支付850基本分。
-- ③：1回合1次，自己把仪式怪兽特殊召唤的场合，以那之内的1只为对象才能发动。除永续魔法卡外的1张「新式魔厨」卡或「食谱」卡从卡组加入手卡，作为对象的怪兽的等级上升1星。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含卡片发动、改变对方怪兽表示形式的永续效果、每次仪式怪兽效果解放怪兽时让对方支付基本分的触发效果，以及自己特殊召唤仪式怪兽时检索卡片并提升等级的诱发效果。
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
	-- ①：只要自己场上有「新式魔厨」怪兽卡存在，对方场上的表侧表示怪兽变成攻击表示。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SET_POSITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.poscon)
	e2:SetTarget(s.target)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetValue(POS_FACEUP_ATTACK)
	c:RegisterEffect(e2)
	-- ②：每次仪式怪兽的效果让怪兽被解放，对方支付850基本分。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_RELEASE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(s.lpcon)
	e3:SetOperation(s.lpop)
	c:RegisterEffect(e3)
	-- 为单张卡片注册一个合并的延迟特殊召唤成功事件监听器，用于处理同一时点内复数怪兽被特殊召唤的情况。
	local custom_code=aux.RegisterMergedDelayedEvent_ToSingleCard(c,id,EVENT_SPSUMMON_SUCCESS)
	-- ③：1回合1次，自己把仪式怪兽特殊召唤的场合，以那之内的1只为对象才能发动。除永续魔法卡外的1张「新式魔厨」卡或「食谱」卡从卡组加入手卡，作为对象的怪兽的等级上升1星。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))  --"检索"
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(custom_code)
	e4:SetRange(LOCATION_SZONE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1)
	e4:SetCondition(s.thcon)
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)
end
-- 过滤函数：检查卡片是否为表侧表示的「新式魔厨」怪兽卡（包括原本是怪兽的魔法/陷阱卡）。
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x196) and c:GetOriginalType()&TYPE_MONSTER==TYPE_MONSTER
end
-- 改变表示形式效果的适用条件：自己场上存在「新式魔厨」怪兽卡。
function s.poscon(e)
	-- 检查自己场上是否存在至少1张满足条件的「新式魔厨」怪兽卡。
	return Duel.IsExistingMatchingCard(s.cfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
end
-- 改变表示形式效果的影响对象过滤：对方场上表侧表示的怪兽。
function s.target(e,c)
	return c:IsFaceup()
end
-- 过滤函数：检查被解放的卡是否是因效果而被解放的怪兽。
function s.cfilter2(c)
	return c:IsType(TYPE_MONSTER) and c:IsReason(REASON_EFFECT)
end
-- 对方支付基本分效果的触发条件：有怪兽因仪式怪兽的效果而被解放。
function s.lpcon(e,tp,eg,ep,ev,re,r,rp)
	return re and re:GetHandler():IsAllTypes(TYPE_RITUAL+TYPE_MONSTER)
		and eg:IsExists(s.cfilter2,1,nil)
end
-- 对方支付基本分效果的处理：若对方基本分在850以上，则让对方支付850基本分。
function s.lpop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方玩家的当前基本分是否大于或等于850。
	if Duel.GetLP(1-tp)>=850 then
		-- 向双方玩家展示此卡，提示此卡的效果正在不入连锁地进行处理。
		Duel.Hint(HINT_CARD,0,id)
		-- 让对方玩家支付850基本分。
		Duel.PayLPCost(1-tp,850)
	end
end
-- 过滤函数：检查是否为自己特殊召唤成功、且可以作为效果对象的表侧表示仪式怪兽（等级在1星以上）。
function s.cfilter3(c,tp,e)
	return c:IsLocation(LOCATION_MZONE) and c:IsSummonPlayer(tp) and c:IsFaceup()
		and c:IsCanBeEffectTarget(e) and c:IsType(TYPE_RITUAL) and c:IsLevelAbove(1)
end
-- 检索并升星效果的触发条件：自己特殊召唤了仪式怪兽。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter3,1,nil,tp,e)
end
-- 过滤函数：检查卡片是否为除永续魔法卡以外的「新式魔厨」卡或「食谱」卡，且可以加入手卡。
function s.thfilter(c)
	return c:IsSetCard(0x196,0x197) and not c:IsAllTypes(TYPE_CONTINUOUS+TYPE_SPELL) and c:IsAbleToHand()
end
-- 检索并升星效果的靶向与发动准备：筛选出符合条件的特殊召唤的仪式怪兽作为对象，并声明检索卡片的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=eg:Filter(s.cfilter3,nil,tp,e)
	if chkc then return g:IsContains(chkc) end
	-- 效果发动时的可行性检查：是否存在可作为对象的仪式怪兽，且卡组中是否存在可检索的卡。
	if chk==0 then return #g>0 and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	local sg
	if g:GetCount()==1 then
		sg=g:Clone()
		-- 将选定的唯一一只仪式怪兽注册为当前连锁的效果对象。
		Duel.SetTargetCard(sg)
	else
		-- 提示玩家选择效果的对象。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
		-- 让玩家从符合条件的特殊召唤怪兽组中选择1只作为效果对象。
		sg=Duel.SelectTarget(tp,aux.IsInGroup,tp,LOCATION_MZONE,0,1,1,nil,g)
	end
	-- 设置当前连锁的操作信息为：从卡组将1张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索并升星效果的处理：从卡组选择1张符合条件的卡加入手卡并给对方确认，然后让作为对象的怪兽等级上升1星。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张符合条件的「新式魔厨」卡或「食谱」卡。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡因效果加入手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡。
		Duel.ConfirmCards(1-tp,g)
		-- 获取当前连锁中被选为对象的仪式怪兽。
		local tc=Duel.GetFirstTarget()
		if tc:IsFaceup() and tc:IsRelateToChain() and tc:IsType(TYPE_MONSTER) then
			-- 作为对象的怪兽的等级上升1星。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_LEVEL)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetValue(1)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
	end
end
