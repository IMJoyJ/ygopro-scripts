--Readying of Rites
-- 效果：
-- 从卡组把1只恶魔族仪式怪兽加入手卡，把灵摆怪兽加入手卡的场合，可以再在自己场上把1只「牺牲供物衍生物」（恶魔族·暗属性·1星·攻300/守300）特殊召唤。只要这衍生物在自己场上存在，自己不能从额外卡组特殊召唤。
-- 自己的仪式怪兽给与对方战斗伤害时：可以把自己墓地的这张卡除外；自己抽1张。
-- 「仪式的筹备」的每个效果1回合各能使用1次。
local s,id,o=GetID()
-- 初始化并注册卡片效果
function s.initial_effect(c)
	-- 从卡组把1只恶魔族仪式怪兽加入手卡，把灵摆怪兽加入手卡的场合，可以再在自己场上把1只「牺牲供物衍生物」（恶魔族·暗属性·1星·攻300/守300）特殊召唤。只要这衍生物在自己场上存在，自己不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCountLimit(1,id)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 自己的仪式怪兽给与对方战斗伤害时：可以把自己墓地的这张卡除外；自己抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"抽卡"
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetCountLimit(1,id+o)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCondition(s.drcon)
	-- 将墓地的这张卡除外作为发动的Cost
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
end
-- 过滤条件：卡组中的恶魔族仪式怪兽
function s.thfilter(c)
	return c:IsAllTypes(TYPE_RITUAL+TYPE_MONSTER) and c:IsRace(RACE_FIEND) and c:IsAbleToHand()
end
-- 效果1（检索/特招衍生物）的发动准备与合法性检测
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可检索的恶魔族仪式怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果1（检索/特招衍生物）的效果处理
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1只满足条件的恶魔族仪式怪兽
	local tc=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if tc then
		-- 将选中的怪兽加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 给对方确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,tc)
		-- 检查加入手牌的怪兽是否为灵摆怪兽，且自己场上是否有空余的怪兽区域
		if tc:IsType(TYPE_PENDULUM) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 检查玩家是否可以特殊召唤该衍生物
			and Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,300,300,1,RACE_FIEND,ATTRIBUTE_DARK)
			-- 询问玩家是否选择特殊召唤衍生物
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否特殊召唤衍生物？"
			-- 中断当前效果处理，使后续特招处理不与加入手牌视为同时进行
			Duel.BreakEffect()
			-- 创建衍生物卡片
			local token=Duel.CreateToken(tp,id+o)
			-- 执行衍生物的特殊召唤步骤
			Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
			-- 只要这衍生物在自己场上存在，自己不能从额外卡组特殊召唤。自己的仪式怪兽给与对方战斗伤害时：可以把自己墓地的这张卡除外；自己抽1张。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e1:SetRange(LOCATION_MZONE)
			e1:SetAbsoluteRange(tp,1,0)
			e1:SetTarget(s.splimit)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_CONTROL)
			token:RegisterEffect(e1,true)
			-- 完成特殊召唤流程
			Duel.SpecialSummonComplete()
		end
	end
end
-- 限制条件：不能从额外卡组特殊召唤
function s.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA)
end
-- 效果2的发动条件：自己的仪式怪兽给与对方战斗伤害时
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=eg:GetFirst()
	return ep~=tp and ec:IsControler(tp) and ec:IsAllTypes(TYPE_RITUAL+TYPE_MONSTER)
end
-- 效果2（抽卡）的发动准备与合法性检测
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家当前是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置效果处理的对象玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置效果处理的对象参数为1
	Duel.SetTargetParam(1)
	-- 设置操作信息：玩家抽卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果2（抽卡）的效果处理
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的对象玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡
	Duel.Draw(p,d,REASON_EFFECT)
end
