--宇宙的ハリケーン
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：场上最多2张卡回到手卡。那之后，双方各自选回到自身手卡的数量的自身手卡，用喜欢的顺序回到卡组下面。
local s,id,o=GetID()
-- 初始化卡片效果：创建效果e1并设置发动描述、回手卡+回卡组分类、魔法卡发动类型、自由时点（可在双方回合主要阶段及伤害步骤以外发动）、同名卡1回合只能发动1张的誓约次数限制，指定目标与处理函数后注册到卡上
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：场上最多2张卡回到手卡。那之后，双方各自选回到自身手卡的数量的自身手卡，用喜欢的顺序回到卡组下面。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 发动时的目标检查与操作信息设置：确认场上存在可以回到手卡的卡作为发动条件，并登记回手卡与回卡组的操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：确认双方场上至少存在1张可以回到手卡的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 取得双方场上所有可以回到手卡的卡组成卡组
	local g=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置操作信息：本次连锁确定要处理回手卡分类，对象是场上可能回到手卡的卡，预计处理至少1张
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	-- 设置操作信息：本次连锁还要处理回卡组分类，预计双方玩家各自从手卡让卡回到卡组（对象在处理时才能确定，故targets为nil）
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,PLAYER_ALL,LOCATION_HAND)
end
-- 过滤函数：判断卡片是否位于玩家tp的手卡中（用于统计回到各自身手卡的数量）
function s.cfilter(c,tp)
	return c:IsLocation(LOCATION_HAND) and c:IsControler(tp)
end
-- 效果处理主体：让发动玩家选场上最多2张卡回到持有者手卡，那之后双方各自从手卡选出相同数量的卡，用喜欢的顺序放回卡组下面
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 向发动玩家显示「请选择要返回手牌的卡」的选择提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让发动玩家从双方场上选择1～2张可以回到手卡的卡
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,2,nil)
	if g:GetCount()>0 then
		-- 为选中的卡显示被选为对象的动画效果
		Duel.HintSelection(g)
		-- 以效果为由将选中的卡送去各自持有者的手卡，并确认至少有1张成功回到手卡
		if Duel.SendtoHand(g,nil,REASON_EFFECT)~=0 then
			-- 取得刚才回到手卡操作实际操作的卡片组
			local og=Duel.GetOperatedGroup()
			local gs={}
			-- 按当前回合玩家开始依次遍历双方玩家
			for p in aux.TurnPlayers() do
				local etg=Group.CreateGroup()
				gs[p]=etg
				if og:IsExists(s.cfilter,1,nil,p) then
					local ct=og:FilterCount(s.cfilter,nil,p)
					-- 向玩家p显示「请选择要返回卡组的卡」的选择提示
					Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
					-- 让玩家p从自己的手卡中选出与回到自身手卡数量相同的卡
					gs[p]=Duel.GetFieldGroup(p,LOCATION_HAND,0):Select(p,ct,ct,nil)
					-- 洗切玩家p的手卡（隐藏被选卡的位置信息）
					Duel.ShuffleHand(p)
				end
			end
			-- 再次按当前回合玩家开始依次遍历双方玩家，准备执行回卡组处理
			for p in aux.TurnPlayers() do
				local sg=gs[p]
				if sg:GetCount()>0 then
					-- 让玩家p把选出的手卡按自己喜欢的顺序放在卡组底端
					aux.PlaceCardsOnDeckBottom(p,sg)
				end
			end
		end
	end
end
