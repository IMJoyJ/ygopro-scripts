--ヴァイロン・スティグマ
-- 效果：
-- 1回合1次，可以把自己场上表侧表示存在的1张名字带有「大日」的装备卡转换给1只别的能变成正确对象的怪兽。这个效果在对方回合也能发动。
function c10712320.initial_effect(c)
	-- 效果原文内容：1回合1次，可以把自己场上表侧表示存在的1张名字带有「大日」的装备卡转换给1只别的能变成正确对象的怪兽。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(10712320,0))  --"装备转移"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c10712320.eqtg)
	e1:SetOperation(c10712320.eqop)
	c:RegisterEffect(e1)
end
-- 检索满足条件的装备卡，该卡必须表侧表示、名字带有「大日」且已装备怪兽。
function c10712320.filter1(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x30) and c:GetEquipTarget()
		-- 检查是否存在能成为该装备卡正确对象的怪兽。
		and Duel.IsExistingTarget(c10712320.filter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,c:GetEquipTarget(),c)
end
-- 检索满足条件的怪兽，该怪兽必须表侧表示且能成为装备卡的正确对象。
function c10712320.filter2(c,eqc)
	return c:IsFaceup() and eqc:CheckEquipTarget(c)
end
-- 效果处理函数，用于选择装备卡和目标怪兽。
function c10712320.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 判断是否满足发动条件，即场上存在符合条件的装备卡。
	if chk==0 then return Duel.IsExistingTarget(c10712320.filter1,tp,LOCATION_SZONE,0,1,nil,tp) end
	-- 提示玩家选择表侧表示的装备卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	-- 选择符合条件的装备卡。
	local g1=Duel.SelectTarget(tp,c10712320.filter1,tp,LOCATION_SZONE,0,1,1,nil,tp)
	local eqc=g1:GetFirst()
	e:SetLabelObject(eqc)
	-- 提示玩家选择要装备的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	-- 选择符合条件的怪兽作为装备对象。
	local g2=Duel.SelectTarget(tp,c10712320.filter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,eqc:GetEquipTarget(),eqc)
end
-- 效果执行函数，用于执行装备转移操作。
function c10712320.eqop(e,tp,eg,ep,ev,re,r,rp)
	local eqc=e:GetLabelObject()
	-- 获取当前连锁中的对象卡片组。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tc=g:GetFirst()
	if tc==eqc then tc=g:GetNext() end
	if not eqc:IsRelateToEffect(e) then return end
	-- 将装备卡装备给目标怪兽。
	Duel.Equip(tp,eqc,tc)
end
