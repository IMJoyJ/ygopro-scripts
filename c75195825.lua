--竜剣士マスターP
-- 效果：
-- ←3 【灵摆】 3→
-- ①：只在这张卡在灵摆区域存在才有1次，以自己或者对方的灵摆区域1张卡为对象才能发动。那张卡破坏。
-- 【怪兽描述】
-- 得到志同道合之士们的力量后「龙剑士 光辉星·灵摆」成长的模样。他是被施过不明神秘诅咒后显现出类似龙魔族的龙之力，但在此之前的记忆全部丢失了，真相因此不明。他相信“龙化秘法”就是解开那诅咒和记忆的关键，今天仍旧继续着前去讨伐邪恶魔王的旅程。
function c75195825.initial_effect(c)
	-- 为怪兽卡添加灵摆怪兽属性（注册灵摆召唤及作为灵摆卡的发动）
	aux.EnablePendulumAttribute(c)
	-- ①：只在这张卡在灵摆区域存在才有1次，以自己或者对方的灵摆区域1张卡为对象才能发动。那张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(75195825,0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_PZONE)
	e2:SetProperty(EFFECT_FLAG_NO_TURN_RESET+EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetTarget(c75195825.sctg)
	e2:SetOperation(c75195825.scop)
	c:RegisterEffect(e2)
end
-- 灵摆效果的发动准备与目标选择函数
function c75195825.sctg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_PZONE) end
	-- 在发动阶段，检查双方的灵摆区域是否存在可作为对象的目标卡片
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_PZONE,LOCATION_PZONE,1,nil) end
	-- 向发动效果的玩家发送选择要破坏的卡片的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择双方灵摆区域的1张卡作为效果的对象
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_PZONE,LOCATION_PZONE,1,1,nil)
	-- 设置效果处理的操作信息，声明此效果将破坏选中的1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 灵摆效果的效果处理函数
function c75195825.scop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的作为效果对象的卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将作为对象的卡片因效果破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
