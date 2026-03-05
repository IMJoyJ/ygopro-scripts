--DDバフォメット
-- 效果：
-- ①：1回合1次，以「DD 巴风特」以外的自己场上1只「DD」怪兽为对象，宣言1～8的任意等级才能发动。那只怪兽直到回合结束时变成宣言的等级。这个效果的发动后，直到回合结束时自己不是「DD」怪兽不能特殊召唤。
function c19808608.initial_effect(c)
	-- 效果原文内容：①：1回合1次，以「DD 巴风特」以外的自己场上1只「DD」怪兽为对象，宣言1～8的任意等级才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c19808608.lvtg)
	e1:SetOperation(c19808608.lvop)
	c:RegisterEffect(e1)
end
-- 效果作用：筛选满足条件的怪兽（表侧表示、DD卡组、非自身、等级大于0）
function c19808608.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xaf) and not c:IsCode(19808608) and c:GetLevel()>0
end
-- 效果作用：选择目标怪兽并宣言等级
function c19808608.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c19808608.filter(chkc) end
	-- 效果作用：判断是否有符合条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(c19808608.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 效果作用：提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 效果作用：选择符合条件的怪兽作为目标
	local g=Duel.SelectTarget(tp,c19808608.filter,tp,LOCATION_MZONE,0,1,1,nil)
	local lv=g:GetFirst():GetLevel()
	-- 效果作用：提示玩家宣言等级
	Duel.Hint(HINT_SELECTMSG,tp,HINGMSG_LVRANK)
	-- 效果作用：记录玩家宣言的等级
	e:SetLabel(Duel.AnnounceLevel(tp,1,8,lv))
end
-- 效果作用：设置目标怪兽等级变更并禁止特殊召唤
function c19808608.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 效果原文内容：那只怪兽直到回合结束时变成宣言的等级。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
	-- 效果原文内容：这个效果的发动后，直到回合结束时自己不是「DD」怪兽不能特殊召唤。
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c19808608.splimit)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 效果作用：将禁止特殊召唤效果注册给玩家
	Duel.RegisterEffect(e2,tp)
end
-- 效果作用：限制非DD怪兽的特殊召唤
function c19808608.splimit(e,c)
	return not c:IsSetCard(0xaf)
end
