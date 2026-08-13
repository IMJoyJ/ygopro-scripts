--デスカイザー・ドラゴン
-- 效果：
-- 「僵尸带菌者」＋调整以外的不死族怪兽1只以上
-- ①：这张卡特殊召唤成功时，以对方墓地1只不死族怪兽为对象才能发动。那只不死族怪兽在自己场上攻击表示特殊召唤。这张卡从场上离开时那只怪兽破坏。
function c6021033.initial_effect(c)
	-- 将「僵尸带菌者」（卡号33420078）加入这张卡的同调素材素材名列表，使这张卡能正确识别所需素材。
	aux.AddMaterialCodeList(c,33420078)
	-- 注册同调召唤手续：调整必须为「僵尸带菌者」，调整以外的不死族怪兽1只以上可作为其他素材。
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsCode,33420078),aux.NonTuner(Card.IsRace,RACE_ZOMBIE),1)
	c:EnableReviveLimit()
	-- ①：这张卡特殊召唤成功时，以对方墓地1只不死族怪兽为对象才能发动。那只不死族怪兽在自己场上攻击表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(6021033,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(c6021033.sptg)
	e1:SetOperation(c6021033.spop)
	c:RegisterEffect(e1)
	-- 这张卡从场上离开时那只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetOperation(c6021033.desop)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
end
-- 定义效果对象过滤器：对象必须是不死族怪兽，且能被当前效果特殊召唤为表侧攻击表示。
function c6021033.filter(c,e,tp)
	return c:IsRace(RACE_ZOMBIE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end
-- 目标合法性检查：若正在验证目标，则目标必须在对方墓地、是不死族且满足特殊召唤条件；若为发动时点检查，则需存在合法目标。
function c6021033.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and c6021033.filter(chkc,e,tp) end
	-- 效果发动条件：自己场上主要怪兽区拥有可用空格，用于特殊召唤怪兽。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 效果发动条件：对方墓地存在1只以上符合条件的不死族怪兽，且能成为本效果对象。
		and Duel.IsExistingTarget(c6021033.filter,tp,0,LOCATION_GRAVE,1,nil,e,tp) end
	-- 发送选择提示消息，让玩家选择要特殊召唤的不死族怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从对方墓地选择1只不死族怪兽作为效果对象，并设置当前连锁的对象。
	local g=Duel.SelectTarget(tp,c6021033.filter,tp,0,LOCATION_GRAVE,1,1,nil,e,tp)
	-- 设置操作信息为特殊召唤，对象为所选怪兽，数量为1，供其他效果连锁时参考。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：将对象不死族怪兽特殊召唤到自己场上表侧攻击表示；成功后把该对象记录到效果标签及标记中，以便本卡离场时破坏它。
function c6021033.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取出当前连锁中记录的对象卡（对方墓地那只不死族怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsRace(RACE_ZOMBIE)
		-- 将对象不死族怪兽特殊召唤到己方场上表侧攻击表示，并判断是否成功。
		and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_ATTACK)~=0 then
		if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
		c:SetCardTarget(tc)
		e:SetLabelObject(tc)
		tc:RegisterFlagEffect(6021033,RESET_EVENT+RESETS_STANDARD,0,0)
		c:RegisterFlagEffect(6021033,RESET_EVENT+0x1020000,0,0)
	end
end
-- 本卡离场时，取得之前特殊召唤并关联的不死族怪兽；若该怪兽仍存在且标记有效，则将其破坏。
function c6021033.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject():GetLabelObject()
	if tc and tc:GetFlagEffect(6021033)~=0 and e:GetHandler():GetFlagEffect(6021033)~=0 then
		-- 以效果破坏那只关联的不死族怪兽。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
