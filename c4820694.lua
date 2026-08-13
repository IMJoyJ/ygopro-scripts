--セイクリッド・テンペスト
-- 效果：
-- 「星圣暴风」的①的效果在决斗中只能使用1次。
-- ①：自己结束阶段以自己场上2只持有超量素材的「星圣」超量怪兽为对象才能发动。那2只超量怪兽的超量素材全部取除，对方基本分变成一半。
-- ②：自己准备阶段以自己场上1只「星圣」超量怪兽和自己墓地1只「星圣」怪兽为对象才能发动。那只墓地的怪兽在那只超量怪兽下面重叠作为超量素材。
function c4820694.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 「星圣暴风」的①的效果在决斗中只能使用1次。①：自己结束阶段以自己场上2只持有超量素材的「星圣」超量怪兽为对象才能发动。那2只超量怪兽的超量素材全部取除，对方基本分变成一半。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(4820694,0))  --"基本分变化"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,4820694+EFFECT_COUNT_CODE_DUEL)
	e2:SetCondition(c4820694.condition)
	e2:SetTarget(c4820694.lptg)
	e2:SetOperation(c4820694.lpop)
	c:RegisterEffect(e2)
	-- ②：自己准备阶段以自己场上1只「星圣」超量怪兽和自己墓地1只「星圣」怪兽为对象才能发动。那只墓地的怪兽在那只超量怪兽下面重叠作为超量素材。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(4820694,1))  --"超量素材增加"
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetRange(LOCATION_SZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1)
	e3:SetCondition(c4820694.condition)
	e3:SetTarget(c4820694.mattg)
	e3:SetOperation(c4820694.matop)
	c:RegisterEffect(e3)
end
-- 效果发动条件函数：判定当前回合玩家是否为效果持有者，即只有在自己回合的对应阶段才能发动。
function c4820694.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前回合玩家是否等于效果控制者，确保在己方回合才能发动。
	return Duel.GetTurnPlayer()==tp
end
-- ①效果的对象筛选条件：过滤出自己场上表侧表示、属于「星圣」系列、超量怪兽且持有超量素材的怪兽。
function c4820694.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x53) and c:IsType(TYPE_XYZ) and c:GetOverlayCount()>0
end
-- ①效果的发动时点与对象选取流程：先确认可以选择2只符合条件的对象，然后让玩家选择2只表侧表示且持有超量素材的「星圣」超量怪兽。
function c4820694.lptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c4820694.filter(chkc) end
	-- 发动合法性检查：确认自己场上是否存在至少2只符合条件的「星圣」超量怪兽可以作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(c4820694.filter,tp,LOCATION_MZONE,0,2,nil) end
	-- 向玩家显示“请选择表侧表示的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家选择2只符合条件的「星圣」超量怪兽，并将它们登记为当前连锁的效果对象。
	Duel.SelectTarget(tp,c4820694.filter,tp,LOCATION_MZONE,0,2,2,nil)
end
-- ①效果处理：取除2只对象超量怪兽的全部超量素材并送入墓地，然后将对方基本分变成一半。
function c4820694.lpop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁处理时登记的效果对象（即被选中的2只超量怪兽）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tc1=g:GetFirst()
	local tc2=g:GetNext()
	if tc1:IsRelateToEffect(e) and tc2:IsRelateToEffect(e) then
		local og1=tc1:GetOverlayGroup()
		local og2=tc2:GetOverlayGroup()
		og1:Merge(og2)
		-- 将所有取除的超量素材送入墓地；若实际送入墓地的数量不足（有卡未能送墓），则中止效果处理。
		if Duel.SendtoGrave(og1,REASON_EFFECT)<og1:GetCount() then return end
		-- 将对方基本分设置为当前值的一半（向上取整）。
		Duel.SetLP(1-tp,math.ceil(Duel.GetLP(1-tp)/2))
	end
end
-- ②效果的超量怪兽对象筛选条件：过滤出自己场上表侧表示、属于「星圣」系列的超量怪兽。
function c4820694.tgfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x53) and c:IsType(TYPE_XYZ)
end
-- ②效果的墓地素材对象筛选条件：过滤出自己墓地中属于「星圣」系列、且可以作为超量素材叠放的怪兽。
function c4820694.mfilter(c)
	return c:IsSetCard(0x53) and c:IsType(TYPE_MONSTER) and c:IsCanOverlay()
end
-- ②效果的发动条件确认与对象选取流程：确认自己场上存在符合条件的「星圣」超量怪兽，且墓地存在符合条件的「星圣」怪兽。
function c4820694.mattg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查是否至少存在1只符合条件的「星圣」超量怪兽可以选为对象。
	if chk==0 then return Duel.IsExistingTarget(c4820694.tgfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 同时检查墓地是否至少存在1只符合条件的「星圣」怪兽可以选为对象。
		and Duel.IsExistingTarget(c4820694.mfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家显示“请选择表侧表示的卡”的提示信息，用于选择场上的超量怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上1只「星圣」超量怪兽作为效果对象，并将该卡记录到效果e的标签对象中以便处理时使用。
	local g1=Duel.SelectTarget(tp,c4820694.tgfilter,tp,LOCATION_MZONE,0,1,1,nil)
	e:SetLabelObject(g1:GetFirst())
	-- 向玩家显示“请选择要作为超量素材的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
	-- 选择墓地中1只「星圣」怪兽作为效果对象，并登记为当前连锁的对象。
	local g2=Duel.SelectTarget(tp,c4820694.mfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 登记此效果涉及墓地卡片移动，用于“王家长眠之谷”等涉及墓地效果的卡进行应对或无效。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g2,1,0,0)
end
-- 处理时的筛选条件：过滤出仍然与效果相关且可以作为超量素材叠放的墓地怪兽。
function c4820694.matfilter(c,e)
	return c:IsRelateToEffect(e) and c:IsCanOverlay()
end
-- ②效果处理：确认目标超量怪兽仍合法后，将选择的墓地怪兽重叠到该超量怪兽下面作为超量素材。
function c4820694.matop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsImmuneToEffect(e) then return end
	-- 从连锁对象中筛选出仍然与效果相关且可作为超量素材的墓地怪兽。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(c4820694.matfilter,tc,e)
	if g:GetCount()>0 then
		-- 将筛选出的墓地怪兽作为超量素材叠放在目标超量怪兽下面。
		Duel.Overlay(tc,g)
	end
end
