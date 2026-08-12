--魔装機関車 デコイチ
-- 效果：
-- 反转：抽1张卡。若自己场上存在表侧表示的「魔货物车辆 博科伊奇」的场合，再抽「魔货物车辆 博科伊奇」数量的卡。
function c87621407.initial_effect(c)
	-- 反转：抽1张卡。若自己场上存在表侧表示的「魔货物车辆 博科伊奇」的场合，再抽「魔货物车辆 博科伊奇」数量的卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(87621407,0))  --"抽卡"
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c87621407.target)
	e1:SetOperation(c87621407.operation)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示的「魔货物车辆 博科伊奇」
function c87621407.filter(c)
	return c:IsFaceup() and c:IsCode(8715625)
end
-- 效果发动的目标确认函数
function c87621407.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 计算自己场上表侧表示的「魔货物车辆 博科伊奇」的数量
	local ct=Duel.GetMatchingGroupCount(c87621407.filter,tp,LOCATION_ONFIELD,0,nil)
	-- 设置当前连锁的对象玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的对象参数为1（基本抽卡张数）
	Duel.SetTargetParam(1)
	-- 设置操作信息：抽卡分类，数量为1张加上「魔货物车辆 博科伊奇」的数量
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct+1)
end
-- 效果处理的执行函数
function c87621407.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的对象玩家和对象参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 计算自己场上表侧表示的「魔货物车辆 博科伊奇」的数量
	local ct=Duel.GetMatchingGroupCount(c87621407.filter,tp,LOCATION_ONFIELD,0,nil)
	-- 如果成功抽卡且自己场上存在「魔货物车辆 博科伊奇」
	if Duel.Draw(p,d,REASON_EFFECT)~=0 and ct>0 then
		-- 中断效果处理，使后续抽卡不视为同时处理
		Duel.BreakEffect()
		-- 再抽「魔货物车辆 博科伊奇」数量的卡
		Duel.Draw(p,ct,REASON_EFFECT)
	end
end
