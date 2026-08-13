--ファイアウォール・S・ドラゴン
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：这张卡同调召唤的场合，以自己的墓地·除外状态的1只电子界族怪兽为对象才能发动。那只怪兽加入手卡。
-- ②：以自己场上1只其他的电子界族怪兽为对象才能发动。这张卡的等级变成和那只怪兽相同。
-- ③：这张卡作为连接素材送去墓地的场合才能发动。从卡组把1张「“艾”」魔法卡加入手卡。
local s,id,o=GetID()
-- 为防火剑刃龙注册同调召唤手续（调整＋调整以外1只以上）并启用苏生限制，同时注册3个效果：①同调召唤成功时回收墓地/除外的电子界族怪兽，②起动效果改变自身等级为其他电子界族怪兽的等级，③作为连接素材时从卡组检索1张『“艾”』魔法卡；各效果均以本卡名作为1回合1次的限制。
function s.initial_effect(c)
	-- 给这张卡添加同调召唤手续：需要1只任意调整怪兽＋1只以上任意调整以外的怪兽作为同调素材。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡同调召唤的场合，以自己的墓地·除外状态的1只电子界族怪兽为对象才能发动。那只怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"回收效果"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：以自己场上1只其他的电子界族怪兽为对象才能发动。这张卡的等级变成和那只怪兽相同。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"改变等级"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.lvtg)
	e2:SetOperation(s.lvop)
	c:RegisterEffect(e2)
	-- ③：这张卡作为连接素材送去墓地的场合才能发动。从卡组把1张「“艾”」魔法卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"检索"
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id+o*2)
	e3:SetCondition(s.thcon2)
	e3:SetTarget(s.thtg2)
	e3:SetOperation(s.thop2)
	c:RegisterEffect(e3)
end
-- ①效果的发动条件：这张卡以同调召唤方式特殊召唤成功。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- ①效果的取对象筛选：对象必须是在墓地或除外区且表侧表示、电子界族怪兽，并且能被加入手卡。
function s.thfilter(c)
	return c:IsFaceupEx() and c:IsRace(RACE_CYBERSE)
		and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ①效果发动时的目标处理：确认存在合法对象后，从自己墓地·除外状态选择1只电子界族怪兽作为对象，并设置加入手卡的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and s.thfilter(chkc) end
	-- 发动合法性检查：自己墓地·除外状态存在至少1只符合条件的电子界族怪兽可供选择为对象。
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	-- 向操作玩家显示选择提示信息：请选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己墓地·除外状态选择1只符合条件的电子界族怪兽，并将其登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	-- 设置操作信息：将选中的对象在效果处理时加入持有者手牌，用于连锁判定（如星尘龙、王家长眠之谷等）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ①效果处理：取得对象后，确认对象仍与效果关联且不受王家长眠之谷效果影响，再将对象加入其持有者手牌，并向对方展示加入手牌的卡。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得①效果发动时选择的那1只对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 确认对象仍然与这次效果关联（未被无效或离场等），且对象不因王家长眠之谷效果而无法从墓地/除外加入手牌。
	if tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc) then
		-- 将对象卡以效果原因加入其持有者的手牌。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方玩家展示这张卡，以确认回收成功。
		Duel.ConfirmCards(1-tp,tc)
	end
end
-- ②效果的对象筛选条件：表侧表示、电子界族、等级为1以上且与这张卡当前等级不同的怪兽；调用时会额外排除自身，以符合‘其他’。
function s.lvfilter(c,lv)
	return c:IsFaceup() and c:IsRace(RACE_CYBERSE) and not c:IsLevel(lv) and c:IsLevelAbove(1)
end
-- ②效果发动时的目标处理：确认这张卡有等级（1以上）且场上存在符合条件的其他电子界族怪兽后，选择其中1只作为对象。
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.lvfilter(chkc,c:GetLevel()) and chkc~=c end
	-- 发动合法性检查：这张卡等级为1以上，且自己场上存在至少1只可选择的、等级与这张卡不同的其他电子界族表侧怪兽。
	if chk==0 then return c:IsLevelAbove(1) and Duel.IsExistingTarget(s.lvfilter,tp,LOCATION_MZONE,0,1,c,c:GetLevel()) end
	-- 向操作玩家显示选择提示信息：请选择表侧表示的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从自己场上选择1只除自身外、符合条件的电子界族表侧怪兽作为对象。
	Duel.SelectTarget(tp,s.lvfilter,tp,LOCATION_MZONE,0,1,1,c,c:GetLevel())
end
-- ②效果处理：确认这张卡和对象仍在对场上且表侧表示后，给这张卡附加一个持续效果，使其等级变为对象怪兽当前的等级；该效果在卡片离场、变成里侧等情况下重置。
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得②效果发动时选择的那1只对象怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsType(TYPE_MONSTER) then
		-- 这张卡的等级变成和那只怪兽相同。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(tc:GetLevel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
end
-- ③效果的发动条件：这张卡是作为连接素材被送去墓地，并且处理时这张卡在墓地。
function s.thcon2(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_LINK and e:GetHandler():IsLocation(LOCATION_GRAVE)
end
-- ③效果检索的筛选条件：卡名含有『“艾”』字段的魔法卡，并且可以被加入手牌。
function s.thfilter2(c)
	return c:IsSetCard(0x136) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- ③效果发动时的目标处理：确认卡组存在符合条件的‘艾’魔法卡，并设置加入手牌的操作信息（由于不取对象，目标组为nil）。
function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：卡组中存在至少1张符合条件的‘艾’魔法卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：声明效果处理时将从卡组把符合条件的1张魔法卡加入手牌，用于连锁判定。由于不取对象，所以targets为nil。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ③效果处理：提示玩家从卡组选择1张符合条件的‘艾’魔法卡，加入持有者手牌，并向对方展示。
function s.thop2(e,tp,eg,ep,ev,re,r,rp)
	-- 向操作玩家显示选择提示信息：请选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张符合条件的‘艾’魔法卡。
	local g=Duel.SelectMatchingCard(tp,s.thfilter2,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡以效果原因加入其持有者的手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示这张加入手牌的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
