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
-- 检查目标卡是否为装备魔法卡且能装备给指定怪兽
function c40884383.filter(c,ec)
	return c:IsType(TYPE_EQUIP) and c:CheckEquipTarget(ec)
end
-- 设置效果的目标为己方墓地中的装备魔法卡
function c40884383.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c40884383.filter(chkc,e:GetHandler()) end
	-- 判断己方魔法陷阱区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 判断己方墓地是否存在满足条件的装备魔法卡
		and Duel.IsExistingTarget(c40884383.filter,tp,LOCATION_GRAVE,0,1,nil,e:GetHandler()) end
	-- 向玩家提示选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择1张满足条件的装备魔法卡作为效果对象
	local g=Duel.SelectTarget(tp,c40884383.filter,tp,LOCATION_GRAVE,0,1,1,nil,e:GetHandler())
	-- 设置效果处理信息，标明将有1张卡从墓地离开
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- 将选中的装备魔法卡装备给此卡
function c40884383.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取此效果选择的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 执行装备操作，将目标卡装备给此卡
		Duel.Equip(tp,tc,c)
	end
end
