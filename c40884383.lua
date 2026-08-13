--凶悪犯－チョップマン
-- 效果：
-- 这张卡反转召唤成功时，可以从自己墓地里选择1张装备魔法卡装备在这张卡身上。
function c40884383.initial_effect(c)
	-- 这张卡反转召唤成功时，可以从自己墓地里选择1张装备魔法卡装备在这张卡身上。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(40884383,0))  --"装备"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	e1:SetTarget(c40884383.eqtg)
	e1:SetOperation(c40884383.eqop)
	c:RegisterEffect(e1)
end
-- 过滤函数：判断墓地的卡是否为装备魔法卡，且能否装备给这张怪兽。
function c40884383.filter(c,ec)
	return c:IsType(TYPE_EQUIP) and c:CheckEquipTarget(ec)
end
-- 取对象判定：处理选卡时确认对象在墓地且属于自己并满足装备条件；发动时确认可行且墓地有满足条件的装备魔法卡。
function c40884383.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c40884383.filter(chkc,e:GetHandler()) end
	-- 检查自己魔陷区是否有空位来装备这张装备魔法卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查自己墓地是否存在至少1张能满足条件的装备魔法卡。
		and Duel.IsExistingTarget(c40884383.filter,tp,LOCATION_GRAVE,0,1,nil,e:GetHandler()) end
	-- 提示发动者选择要装备的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 从自己墓地选择1张符合条件的装备魔法卡作为效果对象。
	local g=Duel.SelectTarget(tp,c40884383.filter,tp,LOCATION_GRAVE,0,1,1,nil,e:GetHandler())
	-- 设置操作信息，表示这些卡将离开墓地，触发相关墓地联动效果。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- 效果处理：若对象仍与效果相关，则将选中的装备魔法卡装备给这张怪兽。
function c40884383.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果处理时选择的装备魔法卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将这张装备魔法卡装备给这张怪兽。
		Duel.Equip(tp,tc,c)
	end
end
