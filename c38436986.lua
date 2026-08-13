--壱世壊に軋む爪音
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：自己场上有「珠泪哀歌族」怪兽或者「维萨斯-斯塔弗罗斯特」存在的场合，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽变成里侧守备表示。那之后，从卡组把1只「珠泪哀歌族」怪兽送去墓地。
-- ②：这张卡被效果送去墓地的场合，以自己墓地1只「珠泪哀歌族」怪兽为对象才能发动。那只怪兽加入手卡。
function c38436986.initial_effect(c)
	-- 将卡号56099748（维萨斯-斯塔弗罗斯特）登记为这张卡上记载的卡名，以便后续规则处理时识别卡名提到该怪兽。
	aux.AddCodeList(c,56099748)
	-- ①：自己场上有「珠泪哀歌族」怪兽或者「维萨斯-斯塔弗罗斯特」存在的场合，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽变成里侧守备表示。那之后，从卡组把1只「珠泪哀歌族」怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_TOGRAVE+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,38436986)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCondition(c38436986.condition)
	e1:SetTarget(c38436986.target)
	e1:SetOperation(c38436986.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡被效果送去墓地的场合，以自己墓地1只「珠泪哀歌族」怪兽为对象才能发动。那只怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,38436986)
	e2:SetCondition(c38436986.thcon)
	e2:SetTarget(c38436986.thtg)
	e2:SetOperation(c38436986.thop)
	c:RegisterEffect(e2)
end
-- 定义过滤器：表侧表示的「珠泪哀歌族」怪兽（且位于怪兽区）或表侧表示的「维萨斯-斯塔弗罗斯特」，用于满足①的发动条件。
function c38436986.actcfilter(c)
	return ((c:IsSetCard(0x181) and c:IsLocation(LOCATION_MZONE)) or c:IsCode(56099748)) and c:IsFaceup()
end
-- ①的发动条件判定：自己场上是否存在至少1张满足actcfilter的卡（「珠泪哀歌族」怪兽或「维萨斯-斯塔弗罗斯特」）。
function c38436986.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查己方场上（LOCATION_ONFIELD）是否存在至少1张满足actcfilter的卡，作为效果①的发动条件。
	return Duel.IsExistingMatchingCard(c38436986.actcfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 定义对象过滤器：对方场上的表侧表示怪兽且能够被变为里侧守备表示（用于①的对象选择）。
function c38436986.posfilter(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end
-- 定义过滤器：卡组中的「珠泪哀歌族」怪兽且能够被效果送去墓地（用于①的送墓选择）。
function c38436986.tgfilter(c)
	return c:IsSetCard(0x181) and c:IsAbleToGrave() and c:IsType(TYPE_MONSTER)
end
-- 效果①的发动时目标处理：确认对方场上有表侧且可转为里侧守备的怪兽可取为对象，且卡组中有「珠泪哀歌族」怪兽可送去墓地；随后选择1只对象怪兽，并登记变更表示形式与送墓的操作信息。
function c38436986.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c38436986.posfilter(chkc) end
	-- 发动合法性检查：确认对方场上存在至少1只表侧表示且可变为里侧守备表示的怪兽，可作为①的对象。
	if chk==0 then return Duel.IsExistingTarget(c38436986.posfilter,tp,0,LOCATION_MZONE,1,nil)
		-- 同时确认卡组中存在至少1只可送去墓地的「珠泪哀歌族」怪兽，两者都满足时①才能发动。
		and Duel.IsExistingMatchingCard(c38436986.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 给发动者显示“请选择表侧表示的卡”的提示，用于选择对象怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让发动者从对方场上选择1只表侧且可转里侧守备的怪兽作为①的效果对象，并与当前连锁关联。
	local g=Duel.SelectTarget(tp,c38436986.posfilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 登记操作信息：本连锁将对选中的1只对象怪兽进行表示形式变更（变为里侧守备表示）。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
	-- 登记操作信息：本连锁预定从自己卡组把1张卡送去墓地（因为处理时再选卡，目标暂不指定，位置为卡组）。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果①的处理：将对象怪兽变成里侧守备表示；若成功，则再从卡组选1只「珠泪哀歌族」怪兽送去墓地。
function c38436986.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取出①效果选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 确认对象怪兽仍与效果关联、仍为表侧表示，并且成功将其变为里侧守备表示后，才继续后续的送墓处理。
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)>0 then
		-- 给发动者显示“请选择要送去墓地的卡”的提示，用于选择卡组送墓的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 让发动者从卡组选择1只满足条件的「珠泪哀歌族」怪兽（用于送去墓地）。
		local g=Duel.SelectMatchingCard(tp,c38436986.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			-- 中断当前效果处理，使“变成里侧守备表示”与后续“从卡组送去墓地”成为不同时点处理，以避免错过触发时点。
			Duel.BreakEffect()
			-- 将选出的「珠泪哀歌族」怪兽以“效果”的原因从卡组送去墓地。
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
	end
end
-- ②的发动条件：这张卡因卡片效果被送去墓地（不是因为cost、战斗等原因）。
function c38436986.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT)
end
-- 定义②的目标过滤器：自己墓地的「珠泪哀歌族」怪兽且能够被加入手卡。
function c38436986.thfilter(c)
	return c:IsSetCard(0x181) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ②的发动时目标处理：选择自己墓地1只「珠泪哀歌族」怪兽为对象，并登记回收手卡的操作信息。
function c38436986.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c38436986.thfilter(chkc) end
	-- 发动合法性检查：确认自己墓地存在至少1只可作为②对象的「珠泪哀歌族」怪兽。
	if chk==0 then return Duel.IsExistingTarget(c38436986.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 给发动者显示“请选择要加入手牌的卡”的提示，用于选择回收对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让发动者从自己墓地选择1只「珠泪哀歌族」怪兽作为②的效果对象，并与当前连锁关联。
	local g=Duel.SelectTarget(tp,c38436986.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 登记操作信息：将选中的对象怪兽加入持有者手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ②的处理：取得对象怪兽，若仍与效果关联，则将其加入手卡。
function c38436986.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得②效果选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以“效果”的原因加入其持有者的手卡（此处即发动者自己）。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
