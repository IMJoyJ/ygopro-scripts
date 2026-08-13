--RR－ノアール・レイニアス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的回合的自己主要阶段，以自己场上1只「急袭猛禽」怪兽为对象才能发动。和那只怪兽等级不同的1只「急袭猛禽」怪兽从卡组加入手卡。
-- ②：把墓地的这张卡除外才能发动。自己场上的「急袭猛禽」怪兽的等级全部上升1星或全部下降1星。
local s,id,o=GetID()
-- 创建并注册卡片效果：①为起动、取对象、1回合1次的检索效果；②为墓地起动、除外自身为cost、1回合1次的等级变更效果；同时注册全局监听事件，用于记录该卡召唤/特殊召唤成功的标记，满足①的发动条件。
function s.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的回合的自己主要阶段，以自己场上1只「急袭猛禽」怪兽为对象才能发动。和那只怪兽等级不同的1只「急袭猛禽」怪兽从卡组加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。自己场上的「急袭猛禽」怪兽的等级全部上升1星或全部下降1星。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	-- 设置②效果发动时需将墓地的这张卡除外作为代价。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.lvtg)
	e2:SetOperation(s.lvop)
	c:RegisterEffect(e2)
	if not s.global_check then
		s.global_check=true
		-- 这个卡名的①②的效果1回合各能使用1次。①：这张卡召唤·特殊召唤的回合的自己主要阶段，以自己场上1只「急袭猛禽」怪兽为对象才能发动。和那只怪兽等级不同的1只「急袭猛禽」怪兽从卡组加入手卡。②：把墓地的这张卡除外才能发动。自己场上的「急袭猛禽」怪兽的等级全部上升1星或全部下降1星。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SUMMON_SUCCESS)
		ge1:SetLabel(id)
		ge1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		-- 设置通常召唤成功事件的处理操作为aux.sumreg，用于标记“这张卡召唤的回合”，供①效果的发动条件判断。
		ge1:SetOperation(aux.sumreg)
		-- 将通常召唤成功监听效果ge1注册为全局效果（玩家0），使场上任意怪兽通常召唤成功时都触发记录。
		Duel.RegisterEffect(ge1,0)
		local ge2=ge1:Clone()
		ge2:SetCode(EVENT_SPSUMMON_SUCCESS)
		-- 将特殊召唤成功监听效果ge2（ge1的克隆）注册为全局效果，使特殊召唤成功时也触发记录。
		Duel.RegisterEffect(ge2,0)
	end
end
-- ①效果的发动条件：判断此卡是否带有召唤/特殊召唤成功的标记（通过计数flag），有则满足条件。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id)>0
end
-- 定义①效果对象目标的过滤函数：对象必须是表侧表示、属于「急袭猛禽」字段、有等级，并且卡组中存在等级不同的「急袭猛禽」怪兽可检索。
function s.cfilter(c,tp)
	-- 对象怪兽条件：表侧表示、是「急袭猛禽」怪兽、等级大于0，且卡组中存在满足检索条件的卡。
	return c:IsFaceup() and c:IsSetCard(0xba) and c:IsLevelAbove(0) and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,c)
end
-- 定义检索过滤条件：卡组中可作为检索对象的卡需满足——等级与选择的「急袭猛禽」怪兽不同、是怪兽、属于「急袭猛禽」字段、并且能够加入手卡。
function s.thfilter(c,rc)
	return c:GetLevel()~=rc:GetLevel() and c:IsType(TYPE_MONSTER) and c:IsSetCard(0xba) and c:IsAbleToHand()
end
-- ①效果的发动目标设定：选择我方场上1只满足cfilter的「急袭猛禽」怪兽作为对象，并登记效果信息为从卡组将1张卡加入手卡。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.cfilter(chkc,tp) end
	-- 发动时检查：我方场上是否存在1只可作为对象的「急袭猛禽」怪兽（且卡组有可检索的卡），若没有则不能发动。
	if chk==0 then return Duel.IsExistingTarget(s.cfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 选择我方场上1只符合条件的「急袭猛禽」怪兽作为本效果的对象。
	Duel.SelectTarget(tp,s.cfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 设置操作信息：本效果包含从卡组检索1张卡加入手卡（CATEGORY_TOHAND），检索数量为1，位置为卡组。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理：取对象并确认其仍在场上且表侧表示后，从卡组选择1张等级不同的「急袭猛禽」怪兽加入手卡，并向对方展示。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 发送选择提示，提示玩家选择要加入手卡的卡（HINTMSG_ATOHAND）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从卡组中选择1张满足thfilter的「急袭猛禽」怪兽（等级与对象不同）作为检索目标。
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,tc)
		if g:GetCount()>0 then
			-- 将选中的卡加入手卡，处理原因为效果。
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 向对方玩家展示加入手卡的卡，确认检索内容。
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
-- 定义②效果处理对象的过滤条件：我方场上表侧表示、有等级、属于「急袭猛禽」字段的怪兽。
function s.lvfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(0) and c:IsSetCard(0xba)
end
-- ②效果的发动目标检查：我方场上存在至少1只满足lvfilter的怪兽即可发动（不取对象）。
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查是否存在满足lvfilter条件的怪兽，有则合法。
	if chk==0 then return Duel.IsExistingMatchingCard(s.lvfilter,tp,LOCATION_MZONE,0,1,nil) end
end
-- ②效果处理：获取我方场上所有「急袭猛禽」怪兽，根据玩家选择使这些怪兽的等级全部上升1星或全部下降1星，并逐一应用等级变更效果。
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取我方场上所有符合条件的「急袭猛禽」怪兽集合。
	local g=Duel.GetMatchingGroup(s.lvfilter,tp,LOCATION_MZONE,0,nil)
	local sel=0
	local lv=1
	if not g:IsExists(Card.IsLevelAbove,1,nil,2) then
		-- 如果场上不存在等级≥2的「急袭猛禽」怪兽，则只能选择“等级上升”（下降会使等级1的怪兽变0不合法），所以只显示一个选项。
		sel=Duel.SelectOption(tp,aux.Stringid(id,0))  --"等级上升"
	else
		-- 如果场上存在等级≥2的怪兽，则让玩家选择“等级上升”或“等级下降”。
		sel=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))  --"等级上升/等级下降"
	end
	if sel==1 then
		lv=-1
	end
	-- 遍历所有受影响的「急袭猛禽」怪兽，对每只怪兽附加等级变更效果。
	for tc in aux.Next(g) do
		-- 自己场上的「急袭猛禽」怪兽的等级全部上升1星或全部下降1星。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(lv)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
