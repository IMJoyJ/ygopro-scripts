--ヴァイロン・スティグマ
-- 效果：
-- 1回合1次，可以把自己场上表侧表示存在的1张名字带有「大日」的装备卡转换给1只别的能变成正确对象的怪兽。这个效果在对方回合也能发动。
function c10712320.initial_effect(c)
	-- 对应效果原文：「1回合1次，可以把自己场上表侧表示存在的1张名字带有「大日」的装备卡转换给1只别的能变成正确对象的怪兽。这个效果在对方回合也能发动。」
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
-- 筛选可作为转移来源的装备卡：须为我方魔陷区表侧表示、卡名含「大日」且正装备在怪兽身上的装备卡；同时场上必须存在另一只表侧表示怪兽可作为这张装备卡的正确装备对象。
function c10712320.filter1(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x30) and c:GetEquipTarget()
		-- 同时检查场上是否存在至少1只除当前装备对象以外的表侧表示怪兽，使这张装备卡通过CheckEquipTarget判定，即能成为新的正确装备对象。
		and Duel.IsExistingTarget(c10712320.filter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,c:GetEquipTarget(),c)
end
-- 筛选新的装备对象：该怪兽须为表侧表示，且这张「大日」装备卡能够正确装备给它（满足其装备限制）。
function c10712320.filter2(c,eqc)
	return c:IsFaceup() and eqc:CheckEquipTarget(c)
end
-- 效果的发动目标和对象选择处理：先选择1张符合条件的「大日」装备卡存入LabelObject，再选择场上1只除其当前装备对象外、可作为正确装备对象的表侧表示怪兽；若是对单卡的对象合法性检查则直接返回false。
function c10712320.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 发动条件检查：我方魔陷区存在至少1张满足filter1的「大日」装备卡（即存在可转移的装备卡且场上存在潜在的新装备对象）时才可发动。
	if chk==0 then return Duel.IsExistingTarget(c10712320.filter1,tp,LOCATION_SZONE,0,1,nil,tp) end
	-- 向玩家发送“请选择表侧表示的卡”的提示信息，用于接下来选择「大日」装备卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从我方魔陷区选择1张满足filter1的表侧表示「大日」装备卡，并将其登记为本次连锁的效果对象。
	local g1=Duel.SelectTarget(tp,c10712320.filter1,tp,LOCATION_SZONE,0,1,1,nil,tp)
	local eqc=g1:GetFirst()
	e:SetLabelObject(eqc)
	-- 向玩家发送“请选择要装备的卡”的提示信息，用于接下来选择新的装备对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家从双方怪兽区选择1只除外当前装备对象外、能让该装备卡正确装备的表侧表示怪兽，并登记为连锁的效果对象。
	local g2=Duel.SelectTarget(tp,c10712320.filter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,eqc:GetEquipTarget(),eqc)
end
-- 效果处理：取出记录的「大日」装备卡与连锁对象中的新装备对象；若装备卡仍与效果关联，则将其装备给新怪兽，完成装备转移。
function c10712320.eqop(e,tp,eg,ep,ev,re,r,rp)
	local eqc=e:GetLabelObject()
	-- 取得当前连锁处理的效果对象集合，其中包含之前选择的「大日」装备卡和新的装备对象怪兽。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tc=g:GetFirst()
	if tc==eqc then tc=g:GetNext() end
	if not eqc:IsRelateToEffect(e) then return end
	-- 将这张「大日」装备卡实际装备给新选择的怪兽，完成装备转移。
	Duel.Equip(tp,eqc,tc)
end
