--ご隠居の猛毒薬
-- 效果：
-- ①：可以从以下效果选择1个发动。
-- ●自己回复1200基本分。
-- ●给与对方800伤害。
function c8842266.initial_effect(c)
	-- ①：可以从以下效果选择1个发动。●自己回复1200基本分。●给与对方800伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c8842266.target)
	e1:SetOperation(c8842266.operation)
	c:RegisterEffect(e1)
end
-- 效果发动的准备阶段，由玩家选择发动其中一个效果，并注册对应的效果分类、对象玩家和参数
function c8842266.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 在系统缓存中设置提示信息，提示玩家选择要发动的效果
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EFFECT)  --"请选择要发动的效果"
	-- 提供两个选项（回复基本分/造成伤害）供玩家选择，并返回选择的索引
	local op=Duel.SelectOption(tp,aux.Stringid(8842266,0),aux.Stringid(8842266,1))  --"自己回复1200基本分/给与对方800伤害"
	e:SetLabel(op)
	if op==0 then
		e:SetCategory(CATEGORY_RECOVER)
		-- 将效果的对象玩家设置为自己
		Duel.SetTargetPlayer(tp)
		-- 将效果的对象参数设置为1200
		Duel.SetTargetParam(1200)
		-- 向系统申报该效果含有回复基本分的操作，涉及玩家为自己，数值为1200
		Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,1200)
	else
		e:SetCategory(CATEGORY_DAMAGE)
		-- 将效果的对象玩家设置为对方
		Duel.SetTargetPlayer(1-tp)
		-- 将效果的对象参数设置为800
		Duel.SetTargetParam(800)
		-- 向系统申报该效果含有造成伤害的操作，涉及玩家为对方，数值为800
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,800)
	end
end
-- 效果处理的执行函数，根据之前选择的分支执行回复或伤害处理
function c8842266.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动阶段中设置的对象玩家和参数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	if e:GetLabel()==0 then
		-- 执行回复基本分的操作
		Duel.Recover(p,d,REASON_EFFECT)
	-- 执行造成伤害的操作
	else Duel.Damage(p,d,REASON_EFFECT) end
end
