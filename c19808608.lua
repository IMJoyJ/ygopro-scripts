--DDバフォメット
-- 效果：
-- ①：1回合1次，以「DD 巴风特」以外的自己场上1只「DD」怪兽为对象，宣言1～8的任意等级才能发动。那只怪兽直到回合结束时变成宣言的等级。这个效果的发动后，直到回合结束时自己不是「DD」怪兽不能特殊召唤。
function c19808608.initial_effect(c)
	-- ①：1回合1次，以「DD 巴风特」以外的自己场上1只「DD」怪兽为对象，宣言1～8的任意等级才能发动。那只怪兽直到回合结束时变成宣言的等级。这个效果的发动后，直到回合结束时自己不是「DD」怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c19808608.lvtg)
	e1:SetOperation(c19808608.lvop)
	c:RegisterEffect(e1)
end
-- 定义过滤器函数，筛选出表侧表示的「DD」怪兽（0xaf），且不是自身卡（19808608），并且等级大于0
function c19808608.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xaf) and not c:IsCode(19808608) and c:GetLevel()>0
end
-- 设置效果的目标函数和操作函数，确定玩家可以选择符合条件的「DD」怪兽并宣言等级
function c19808608.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c19808608.filter(chkc) end
	-- 检查自己场上是否存在符合条件的对象：表侧表示的「DD」怪兽（不包括自身）
	if chk==0 then return Duel.IsExistingTarget(c19808608.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从自己怪兽区选择1只符合条件的「DD」怪兽作为对象
	local g=Duel.SelectTarget(tp,c19808608.filter,tp,LOCATION_MZONE,0,1,1,nil)
	local lv=g:GetFirst():GetLevel()
	-- 提示玩家宣言等级（1～8）
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LVRANK)
	-- 获取玩家宣言的等级并设置为效果的标签值，供后续操作使用
	e:SetLabel(Duel.AnnounceLevel(tp,1,8,lv))
end
-- 效果处理函数：将被选中的怪兽等级变为宣言的等级，并限制本回合不能非DD怪兽特殊召唤
function c19808608.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 那只怪兽直到回合结束时变成宣言的等级
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
	-- 这个效果的发动后，直到回合结束时自己不是「DD」怪兽不能特殊召唤
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c19808608.splimit)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 注册一个玩家级别的永续效果，限制玩家在回合结束前不能特殊召唤非「DD」怪兽
	Duel.RegisterEffect(e2,tp)
end
-- 限制函数：检查要特殊召唤的怪兽是否为「DD」怪兽，不是则禁止特殊召唤
function c19808608.splimit(e,c)
	return not c:IsSetCard(0xaf)
end
