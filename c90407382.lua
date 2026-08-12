--ザ・キックマン
-- 效果：
-- 这张卡特殊召唤成功时，可以将1张存在于自己墓地里的装备魔法卡装备在这张卡身上。
function c90407382.initial_effect(c)
	-- 这张卡特殊召唤成功时，可以将1张存在于自己墓地里的装备魔法卡装备在这张卡身上。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(90407382,0))  --"装备"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(c90407382.eqtg)
	e1:SetOperation(c90407382.eqop)
	c:RegisterEffect(e1)
end
-- 过滤函数：筛选自己墓地中可以装备给当前怪兽的装备魔法卡
function c90407382.filter(c,ec)
	return c:IsType(TYPE_EQUIP) and c:CheckEquipTarget(ec)
end
-- 效果发动的目标选择与合法性检查（包括作为对象时的合法性判定）
function c90407382.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c90407382.filter(chkc,e:GetHandler()) end
	-- 检查自己场上是否有可用的魔法与陷阱区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查自己墓地是否存在至少1张可以装备给这张卡的装备魔法卡
		and Duel.IsExistingTarget(c90407382.filter,tp,LOCATION_GRAVE,0,1,nil,e:GetHandler()) end
	-- 提示玩家选择要装备的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择自己墓地1张符合条件的装备魔法卡作为效果对象
	local g=Duel.SelectTarget(tp,c90407382.filter,tp,LOCATION_GRAVE,0,1,1,nil,e:GetHandler())
	-- 设置效果处理信息，表示有1张卡将离开墓地
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- 效果处理：将选择的装备魔法卡装备给这张卡
function c90407382.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取在发动时选择的作为效果对象的装备魔法卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标装备魔法卡装备给这张卡
		Duel.Equip(tp,tc,c)
	end
end
