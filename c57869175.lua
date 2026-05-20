--フォーチュンレディ・パスティー
-- 效果：
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：这张卡的攻击力·守备力变成这张卡的等级×200。
-- ②：自己准备阶段发动。这张卡的等级上升1星（最多到12星）。
-- ③：以自己场上1只「命运女郎」怪兽为对象才能发动。那只怪兽以外的自己的手卡·场上·墓地的魔法师族怪兽任意数量除外，直到回合结束时作为对象的怪兽的等级上升或者下降除外的怪兽数量的数值。
function c57869175.initial_effect(c)
	-- ①：这张卡的攻击力·守备力变成这张卡的等级×200。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_SET_ATTACK)
	e1:SetValue(c57869175.value)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SET_DEFENSE)
	c:RegisterEffect(e2)
	-- ②：自己准备阶段发动。这张卡的等级上升1星（最多到12星）。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(57869175,0))  --"等级上升1星"
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetCondition(c57869175.lvcon)
	e3:SetOperation(c57869175.lvop)
	c:RegisterEffect(e3)
	-- ③：以自己场上1只「命运女郎」怪兽为对象才能发动。那只怪兽以外的自己的手卡·场上·墓地的魔法师族怪兽任意数量除外，直到回合结束时作为对象的怪兽的等级上升或者下降除外的怪兽数量的数值。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(57869175,1))  --"改变等级"
	e4:SetCategory(CATEGORY_REMOVE)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,57869175)
	e4:SetTarget(c57869175.rmtg)
	e4:SetOperation(c57869175.rmop)
	c:RegisterEffect(e4)
end
-- 计算并返回这张卡的等级×200的数值
function c57869175.value(e,c)
	return c:GetLevel()*200
end
-- 等级上升效果的发动条件：当前回合玩家是自己
function c57869175.lvcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为自己
	return Duel.GetTurnPlayer()==tp
end
-- 等级上升效果的处理：若自身表侧表示存在、未离场且等级小于12，则等级上升1星
function c57869175.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) or c:IsLevelAbove(12) then return end
	-- 这张卡的等级上升1星
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示、等级在1以上且有其他可除外魔法师族怪兽的「命运女郎」怪兽
function c57869175.tgfilter(c,tp)
	return c:IsSetCard(0x31) and c:IsLevelAbove(1) and c:IsFaceup()
		-- 检查除作为对象的怪兽外，自己的手卡、场上、墓地是否存在至少1只可以除外的魔法师族怪兽
		and Duel.IsExistingMatchingCard(c57869175.rmfilter,tp,LOCATION_MZONE+LOCATION_HAND+LOCATION_GRAVE,0,1,c)
end
-- 过滤条件：手卡、墓地或场上表侧表示的可以除外的魔法师族怪兽
function c57869175.rmfilter(c)
	return (not c:IsLocation(LOCATION_MZONE) or c:IsFaceup()) and c:IsRace(RACE_SPELLCASTER) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
-- 等级改变效果的发动准备：选择自己场上1只「命运女郎」怪兽作为对象，并声明除外操作信息
function c57869175.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c57869175.tgfilter(chkc,tp) end
	-- 在效果发动阶段的第1步，检查场上是否存在符合条件的「命运女郎」怪兽作为对象
	if chk==0 then return Duel.IsExistingTarget(c57869175.tgfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 在客户端提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家选择自己场上1只符合条件的「命运女郎」怪兽作为效果的对象
	Duel.SelectTarget(tp,c57869175.tgfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 设置效果处理信息：从手卡、场上、墓地将至少1张卡除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_MZONE+LOCATION_HAND+LOCATION_GRAVE)
end
-- 等级改变效果的处理：除外任意数量的魔法师族怪兽，并让对象怪兽的等级上升或下降该数量
function c57869175.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取在发动时选择的作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	local ec=nil
	if tc:IsRelateToEffect(e) then
		ec=tc
	end
	-- 在客户端提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从手卡、场上、墓地选择任意数量（1-99张）除对象怪兽以外的魔法师族怪兽（受王家长眠之谷影响）
	local rg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c57869175.rmfilter),tp,LOCATION_MZONE+LOCATION_HAND+LOCATION_GRAVE,0,1,99,ec,tp)
	-- 如果选择了至少1张卡，则将这些卡以表侧表示除外，并判断是否成功除外
	if rg:GetCount()>0 and Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)~=0 then
		-- 获取本次操作中实际被除外的卡片组
		local og=Duel.GetOperatedGroup()
		local lv=og:FilterCount(Card.IsLocation,nil,LOCATION_REMOVED)
		if lv>0 and tc:IsRelateToEffect(e) then
			local op=0
			-- 如果对象怪兽的等级小于或等于除外的怪兽数量，则只能选择“等级上升”
			if tc:IsLevelBelow(lv) then op=Duel.SelectOption(tp,aux.Stringid(57869175,2))  --"等级上升"
			-- 如果对象怪兽的等级大于除外的怪兽数量，则让玩家选择“等级上升”或“等级下降”
			else op=Duel.SelectOption(tp,aux.Stringid(57869175,2),aux.Stringid(57869175,3)) end  --"等级上升/等级下降"
			-- 直到回合结束时作为对象的怪兽的等级上升或者下降除外的怪兽数量的数值
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_UPDATE_LEVEL)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			if op==0 then
				e1:SetValue(lv)
			else
				e1:SetValue(-lv)
			end
			tc:RegisterEffect(e1)
		end
	end
end
