--ライブラの魔法秤
-- 效果：
-- ←5 【灵摆】 5→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：宣言1～6的任意等级，以自己场上2只表侧表示怪兽为对象才能发动。直到回合结束时，作为对象的1只怪兽的等级下降宣言的等级数值，另1只怪兽的等级上升宣言的等级数值。
-- 【怪兽描述】
-- 拥有意志的天秤。虽然维持着世间的平衡，却常常将锤星放错位置。
function c43857222.initial_effect(c)
	-- 为该卡添加灵摆怪兽属性，使其可以进行灵摆召唤和灵摆卡的发动
	aux.EnablePendulumAttribute(c)
	-- ①：宣言1～6的任意等级，以自己场上2只表侧表示怪兽为对象才能发动。直到回合结束时，作为对象的1只怪兽的等级下降宣言的等级数值，另1只怪兽的等级上升宣言的等级数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(43857222,0))  --"改变等级"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,43857222)
	e1:SetRange(LOCATION_PZONE)
	e1:SetTarget(c43857222.lvtg)
	e1:SetOperation(c43857222.lvop)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于判断场上是否存在满足条件的怪兽（表侧表示且等级大于等于2），并且能作为效果对象
function c43857222.lvfilter1(c,tp)
	return c:IsFaceup() and c:IsLevelAbove(2)
		-- 检查是否存在满足lvfilter2条件的怪兽作为效果对象
		and Duel.IsExistingTarget(c43857222.lvfilter2,tp,LOCATION_MZONE,0,1,c,1)
end
-- 过滤函数，用于判断场上是否存在满足条件的怪兽（表侧表示且等级大于等于lv）
function c43857222.lvfilter2(c,lv)
	return c:IsFaceup() and c:IsLevelAbove(lv)
end
-- 过滤函数，用于判断场上是否存在满足条件的怪兽（表侧表示且等级大于等于1）且可以成为效果对象
function c43857222.tgfilter(c,e)
	return c:IsFaceup() and c:IsLevelAbove(1) and c:IsCanBeEffectTarget(e)
end
-- 检查组中是否存在等级大于lv+1的怪兽
function c43857222.gcheck(g,lv)
	return g:IsExists(Card.IsLevelAbove,1,nil,lv+1)
end
-- 处理效果的发动阶段，检查是否存在满足lvfilter1条件的怪兽，并获取满足条件的怪兽组，然后让玩家宣言等级并选择2只怪兽作为对象
function c43857222.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查是否满足发动条件，即场上存在满足lvfilter1条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c43857222.lvfilter1,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 获取满足tgfilter条件的场上怪兽组
	local g=Duel.GetMatchingGroup(c43857222.tgfilter,tp,LOCATION_MZONE,0,nil,e)
	local _,lv=g:GetMaxGroup(Card.GetLevel)
	-- 让玩家宣言一个等级，范围为1到lv-1之间的最小值
	local alv=Duel.AnnounceLevel(tp,1,math.min(lv-1,6))
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	local tg=g:SelectSubGroup(tp,c43857222.gcheck,false,2,2,alv)
	-- 将选中的怪兽设置为当前效果的对象
	Duel.SetTargetCard(tg)
	e:SetLabel(alv)
end
-- 处理效果的发动效果，获取当前效果的对象组，然后选择一只怪兽降低等级，另一只提升等级
function c43857222.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取与当前连锁相关的对象组
	local g=Duel.GetTargetsRelateToChain()
	if #g==0 then return end
	local lv=e:GetLabel()
	-- 提示玩家选择要下降等级的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(43857222,1))  --"请选择要下降等级的怪兽"
	local tc1=g:FilterSelect(tp,c43857222.lvfilter2,1,1,nil,lv+1):GetFirst()
	if tc1 then
		local c=e:GetHandler()
		local tc2=(g-tc1):GetFirst()
		-- 使选中的怪兽等级下降宣言的等级数值
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(-lv)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		if tc1:RegisterEffect(e1) and tc2 and tc2:IsFaceup() then
			-- 使另一只怪兽等级上升宣言的等级数值
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_UPDATE_LEVEL)
			e2:SetValue(lv)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc2:RegisterEffect(e2)
		end
	end
end
