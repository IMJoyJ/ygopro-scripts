--シンクロ・クリード
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：场上有同调怪兽存在的场合才能发动。自己抽1张。场上有同调怪兽3只以上存在的场合，再让自己可以抽1张。
local s,id,o=GetID()
-- 定义该卡的效果初始化函数：创建一个发动效果e1，设置其分类为抽卡、类型为魔法卡发动、发动时点为自由时点、带有玩家对象标志，并赋予同名卡1回合1次的发动次数限制，同时设置发动条件、发动时处理目标及效果处理函数，最后将e1注册到卡片c上。
function s.initial_effect(c)
	-- 对应卡片效果原文：“这个卡名的卡在1回合只能发动1张。①：场上有同调怪兽存在的场合才能发动。自己抽1张。场上有同调怪兽3只以上存在的场合，再让自己可以抽1张。”
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 定义过滤器函数s.filter：判断卡牌是否为表侧表示的同调怪兽。
function s.filter(c)
	return c:IsType(TYPE_SYNCHRO) and c:IsFaceup()
end
-- 定义效果发动条件函数s.condition：返回场上（双方主要怪兽区）是否存在至少1只满足s.filter的表侧表示同调怪兽，若存在则可发动。
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 调用Duel.IsExistingMatchingCard，从tp视角检索双方场上主要怪兽区，检查是否存在至少1张表侧表示的同调怪兽（排除nil，即不排除卡）。
	return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
-- 定义效果发动时的目标处理函数s.target：在发动合法性检查（chk==0）时确认玩家能否抽1张；若能，则将本次效果的对象玩家设为tp、对象参数设为1（抽卡数），并登记抽卡类别的操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 目标处理中的合法性检查：当chk为0（效果发动未确定）时，仅当发动者tp能够抽1张卡才允许发动此效果。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 将当前连锁处理的对象玩家设置为tp，表示后续效果处理作用于该玩家（抽卡者）。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁处理的对象参数设置为1，表示本次效果预定抽卡张数为1。
	Duel.SetTargetParam(1)
	-- 设置操作信息：声明本连锁将进行CATEGORY_DRAW抽卡，对象卡组不确定故targets为nil、count为0，目标玩家为tp，目标参数为1（抽卡数量），供其他卡片或效果检测。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 定义效果处理函数s.activate：先取得之前保存的抽卡玩家和抽卡数并执行第一次抽卡；若第一次抽卡成功、该玩家仍能抽卡、场上表侧同调怪兽不少于3只，且玩家确认再抽1张，则中断当前连锁后追加抽1张。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出保存的目标玩家p和目标参数d（抽卡张数），供后续抽卡使用。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让玩家p因效果抽d张卡；若实际抽到卡（返回>0）并且玩家p仍可以再抽1张，则继续判断追加抽卡条件。
	if Duel.Draw(p,d,REASON_EFFECT)>0 and Duel.IsPlayerCanDraw(p,1)
		-- 统计以p为视角的双方场上主要怪兽区中表侧表示同调怪兽的数量，若不少于3只，则满足“场上有同调怪兽3只以上存在”的追加抽卡条件。
		and Duel.GetMatchingGroupCount(s.filter,p,LOCATION_MZONE,LOCATION_MZONE,nil)>=3
		-- 询问玩家p是否再抽1张（提示文本“是否再抽1张？”）；只有选择“是”才执行后续的追加抽卡。
		and Duel.SelectYesNo(p,aux.Stringid(id,0)) then  --"是否再抽1张？"
		-- 调用Duel.BreakEffect中断当前效果处理，使之后的追加抽卡视为另一次独立处理（错开时点），不会与第一次抽卡同时结算。
		Duel.BreakEffect()
		-- 让玩家p再抽1张卡，完成“再让自己可以抽1张”的追加抽卡效果。
		Duel.Draw(p,1,REASON_EFFECT)
	end
end
