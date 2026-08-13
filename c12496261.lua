--ドラグニティナイト－ハールーン
-- 效果：
-- 「龙骑兵团」调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤的场合，以自己墓地1只「龙骑兵团」怪兽为对象才能发动。那只怪兽当作装备魔法卡使用给这张卡装备。
-- ②：这张卡被送去墓地的场合，以自己场上1只「龙骑兵团」怪兽为对象才能发动。这张卡当作攻击力·守备力上升1000的装备魔法卡使用给作为对象的自己怪兽装备。
function c12496261.initial_effect(c)
	-- 为这张卡添加同调召唤手续：调整怪兽必须拥有「龙骑兵团」字段，调整以外的怪兽为任意怪兽1只以上，对应召唤素材「龙骑兵团」调整＋调整以外的怪兽1只以上。
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x29),aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 对应效果原文：这个卡名的①②的效果1回合各能使用1次。①：这张卡特殊召唤的场合，以自己墓地1只「龙骑兵团」怪兽为对象才能发动。那只怪兽当作装备魔法卡使用给这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(12496261,0))
	e1:SetCategory(CATEGORY_LEAVE_GRAVE+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,12496261)
	e1:SetTarget(c12496261.eqtg)
	e1:SetOperation(c12496261.eqop)
	c:RegisterEffect(e1)
	-- 对应效果原文：②：这张卡被送去墓地的场合，以自己场上1只「龙骑兵团」怪兽为对象才能发动。这张卡当作攻击力·守备力上升1000的装备魔法卡使用给作为对象的自己怪兽装备。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(12496261,1))
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,12496262)
	e2:SetTarget(c12496261.eqstg)
	e2:SetOperation(c12496261.eqsop)
	c:RegisterEffect(e2)
end
-- 定义①效果可选择对象的筛选条件：对象必须是拥有「龙骑兵团」字段的怪兽卡，且未被禁止效果宣言为不能使用。
function c12496261.filter(c)
	return c:IsSetCard(0x29) and c:IsType(TYPE_MONSTER) and not c:IsForbidden()
end
-- ①效果的目标判定与选择函数：若指定对象chkc则验证其为位于自己墓地且符合筛选条件的「龙骑兵团」怪兽；若在发动时则检查自己魔陷区有空位且墓地存在符合条件的对象。
function c12496261.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c12496261.filter(chkc) end
	-- 检查自己魔陷区是否有空位，以决定能否将墓地选出的怪兽装备到这张卡上。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查自己墓地是否存在1张以上满足条件的「龙骑兵团」怪兽，且该怪兽能成为当前效果的对象。
		and Duel.IsExistingTarget(c12496261.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家显示选择提示，提示内容为“请选择要装备的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家从自己墓地选择1张符合条件的「龙骑兵团」怪兽，并将其登记为当前连锁的效果对象。
	local g=Duel.SelectTarget(tp,c12496261.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：本效果涉及对象卡从墓地离开（CATEGORY_LEAVE_GRAVE），数量为1，用于与墓地相关效果的联动判定。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
	-- 设置操作信息：本效果涉及将对象卡作为装备卡装备（CATEGORY_EQUIP），数量为1。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
end
-- ①效果处理函数：取得对象怪兽，确认其仍与效果相关后，将其作为装备魔法卡装备给这张卡；若装备失败则终止；随后为该装备卡设置只能装备给这张卡的装备限制。
function c12496261.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得①效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 尝试将对象怪兽作为装备魔法卡装备给这张卡，并保持其原本的表示形式；若装备失败则直接终止处理。
		if not Duel.Equip(tp,tc,c,false) then return end
		-- 对应①效果原文：那只怪兽当作装备魔法卡使用给这张卡装备。（此处为装备卡添加装备对象限制，确保只能装备给这张卡）
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c12496261.eqlimit)
		tc:RegisterEffect(e1)
	end
end
-- 定义装备限制判定函数：只有该效果的所有者（e:GetOwner()）才能作为这张装备卡的装备对象，即装备卡只能装备给效果所有者。
function c12496261.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 定义②效果可选择的装备目标条件：目标是己方场上表侧表示且拥有「龙骑兵团」字段的怪兽。
function c12496261.eqfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x29)
end
-- ②效果的目标判定与选择函数：若指定对象chkc则验证其为己方场上表侧表示的「龙骑兵团」怪兽；若在发动时则检查自己魔陷区有空位且场上存在符合条件的对象。
function c12496261.eqstg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c12496261.eqfilter(chkc) end
	-- 检查自己魔陷区是否有空位，用于容纳装备状态的这张卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查自己场上是否存在1只以上表侧表示的「龙骑兵团」怪兽，且能被选择为装备对象。
		and Duel.IsExistingTarget(c12496261.eqfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家显示“请选择要装备的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家选择自己场上1只表侧表示且拥有「龙骑兵团」字段的怪兽，并将其设为效果对象。
	Duel.SelectTarget(tp,c12496261.eqfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息：本效果处理涉及将效果持有者（这张卡）作为装备卡装备，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- ②效果处理函数：若魔陷区有空位且这张卡与对象怪兽仍相关，则将这张卡作为装备魔法卡装备给对象怪兽；为该装备卡设置装备对象限制，并使其获得攻击力·守备力上升1000的装备效果。
function c12496261.eqsop(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己魔陷区没有空位，无法装备这张卡，直接结束效果处理。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local c=e:GetHandler()
	-- 取得②效果选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡作为装备魔法卡装备给对象怪兽。
		Duel.Equip(tp,c,tc)
		-- 对应②效果原文：这张卡当作攻击力·守备力上升1000的装备魔法卡使用给作为对象的自己怪兽装备。（此处实现装备限制部分）
		local e1=Effect.CreateEffect(tc)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c12496261.eqlimit)
		c:RegisterEffect(e1)
		-- 对应②效果原文：攻击力·守备力上升1000。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetValue(1000)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
		local e3=e2:Clone()
		e3:SetCode(EFFECT_UPDATE_DEFENSE)
		c:RegisterEffect(e3)
	end
end
