--下降潮流
-- 效果：
-- 选择自己场上表侧表示存在的1只怪兽，宣言从1到3的任意等级才能发动。选择的怪兽的等级变成宣言的等级。
function c26099457.initial_effect(c)
	-- 选择自己场上表侧表示存在的1只怪兽，宣言从1到3的任意等级才能发动。选择的怪兽的等级变成宣言的等级。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c26099457.target)
	e1:SetOperation(c26099457.activate)
	c:RegisterEffect(e1)
end
-- 对象过滤函数：检查怪兽是否表侧表示且有等级（等级0以上），即可以变更等级的怪兽
function c26099457.filter(c)
	return c:IsFaceup() and c:IsLevelAbove(0)
end
-- 目标函数：选择自己场上1只表侧表示的怪兽作为对象，并让玩家宣言1到3的等级
function c26099457.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c26099457.filter(chkc) end
	-- 发动条件检查：确认自己场上存在至少1只可以成为对象的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c26099457.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家发送选择提示「请选择表侧表示的卡」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让自己玩家选择自己场上1只表侧表示的怪兽，并将其设为当前效果的对象
	local g=Duel.SelectTarget(tp,c26099457.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 向玩家发送宣言等级的选择提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LVRANK)
	-- 让玩家宣言1到3的任意等级（不能宣言对象怪兽当前的等级），并返回宣言的等级
	local lv=Duel.AnnounceLevel(tp,1,3,g:GetFirst():GetLevel())
	e:SetLabel(lv)
end
-- 效果处理：将对象怪兽的等级变成宣言的等级
function c26099457.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁处理的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 选择的怪兽的等级变成宣言的等级。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
