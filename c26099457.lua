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
-- 检索满足条件的卡片组：表侧表示且等级大于等于0的怪兽
function c26099457.filter(c)
	return c:IsFaceup() and c:IsLevelAbove(0)
end
-- 选择自己场上表侧表示存在的1只怪兽作为对象，并让玩家宣言从1到3的任意等级
function c26099457.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c26099457.filter(chkc) end
	-- 判断是否满足发动条件：确认场上是否存在符合条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c26099457.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择一张表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择目标怪兽：从己方场上选择1只符合条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c26099457.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 提示玩家宣言等级
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LVRANK)
	-- 让玩家宣言一个1到3之间的等级，并将该等级保存到效果标签中
	local lv=Duel.AnnounceLevel(tp,1,3,g:GetFirst():GetLevel())
	e:SetLabel(lv)
end
-- 将选定的怪兽等级修改为玩家宣言的等级
function c26099457.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 选择自己场上表侧表示存在的1只怪兽，宣言从1到3的任意等级才能发动。选择的怪兽的等级变成宣言的等级。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
