--リブロマンサー・エージェント
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把手卡1只仪式怪兽给对方观看才能发动。这张卡从手卡特殊召唤。
-- ②：以「书灵师·代理人」以外的自己墓地1张「书灵师」卡为对象才能发动。那张卡加入手卡。这个效果把魔法·陷阱卡加入手卡的场合，再选自己1张手卡回到卡组最下面。
local s,id,o=GetID()
-- 注册①和②两个起动效果：①展示手卡1只仪式怪兽作为cost，将此卡从手卡特殊召唤；②以墓地1张「书灵师」卡为对象加入手卡，若对象是魔法·陷阱卡则再选自己1张手卡返回卡组最下面；两个效果均1回合各能使用1次。
function s.initial_effect(c)
	-- ①：把手卡1只仪式怪兽给对方观看才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：以「书灵师·代理人」以外的自己墓地1张「书灵师」卡为对象才能发动。那张卡加入手卡。这个效果把魔法·陷阱卡加入手卡的场合，再选自己1张手卡回到卡组最下面。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.g2htg)
	e2:SetOperation(s.g2hop)
	c:RegisterEffect(e2)
end
-- 定义cost筛选条件：选择手卡中非公开状态的仪式怪兽，用于给对方观看。
function s.spcostfilter(c)
	return c:IsType(TYPE_RITUAL) and c:IsType(TYPE_MONSTER) and not c:IsPublic()
end
-- 支付①效果的cost：从手卡选择1只仪式怪兽给对方确认，然后洗切手卡。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- cost检查阶段：确认自己手卡中是否存在至少1张可展示的仪式怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.spcostfilter,tp,LOCATION_HAND,0,1,c) end
	-- 显示选择提示，要求玩家选择要展示给对方确认的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 从自己手卡中选择1张符合条件的仪式怪兽（排除本卡自身）作为展示cost。
	local g=Duel.SelectMatchingCard(tp,s.spcostfilter,tp,LOCATION_HAND,0,1,1,c)
	-- 将所选cost展示给对手玩家确认。
	Duel.ConfirmCards(1-tp,g)
	-- 展示后洗切手卡，防止对手根据手卡顺序获知信息。
	Duel.ShuffleHand(tp)
end
-- ①效果的发动条件检查：主要怪兽区有空位且此卡可以被特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己主要怪兽区是否有空位，以确定能否从手卡特殊召唤此卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：声明将要特殊召唤此卡，供连锁和时点检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①效果处理：若此卡仍与效果关联，则将其特殊召唤到己方场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将发动效果的手卡中的此卡以表侧攻击表示特殊召唤。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 墓地筛选条件：卡名含有「书灵师」字段、不是「书灵师·代理人」自身，并且能够加入手卡。
function s.g2hfilter(c)
	return c:IsSetCard(0x17c) and not c:IsCode(id) and c:IsAbleToHand()
end
-- ②效果的目标阶段：从自己墓地选择1张符合条件的「书灵师」卡作为对象；若该卡是魔法·陷阱卡，则同时设置后续要选1张手卡返回卡组的操作信息。
function s.g2htg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.g2hfilter(chkc) end
	-- 检查是否存在至少1张符合条件的墓地「书灵师」卡可以作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(s.g2hfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 显示选择提示，要求玩家选择要加入手卡的墓地卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己墓地选择1张符合条件的「书灵师」卡作为效果对象。
	local g=Duel.SelectTarget(tp,s.g2hfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置将对象卡加入手卡的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,LOCATION_GRAVE)
	if g:GetFirst():IsType(TYPE_SPELL+TYPE_TRAP) then
		-- 由于选择的加入手卡对象是魔法·陷阱卡，设置后续要将1张手卡返回卡组的操作信息（目标为手卡，不确定具体卡）。
		Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,0,LOCATION_HAND)
	end
end
-- ②效果处理：将对象卡加入手卡；若该卡是魔法·陷阱卡且成功入手，则洗切手卡后选择自己1张手卡返回卡组最下面。
function s.g2hop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取②效果取对象选择的墓地卡片。
	local tc=Duel.GetFirstTarget()
	-- 判断对象卡是否仍与效果关联，且成功加入手卡，并且该卡位于手卡且是魔法·陷阱卡，以决定是否进行追加处理。
	if tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0
		and tc:IsLocation(LOCATION_HAND) and tc:IsType(TYPE_SPELL+TYPE_TRAP) then
		-- 在追加处理前洗切手卡，使手牌顺序随机化。
		Duel.ShuffleHand(tp)
		-- 显示选择提示，要求玩家选择要返回卡组的手卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		-- 从自己手卡中选择1张可以返回卡组的卡（不限卡种）。
		local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,1,nil)
		if #g>0 then
			-- 中断当前效果处理，使追加的返回卡组效果作为独立处理，避免错失时点。
			Duel.BreakEffect()
			-- 将所选手卡以效果原因返回持有者卡组最下面。
			Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
		end
	end
end
