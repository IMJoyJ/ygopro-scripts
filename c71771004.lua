--供物の下ごしらえ
-- 效果：
-- 从卡组把1只恶魔族仪式怪兽加入手卡，把灵摆怪兽加入手卡的场合，可以再在自己场上把1只「牺牲供物衍生物」（恶魔族·暗属性·1星·攻300/守300）特殊召唤。只要这衍生物在自己场上存在，自己不能从额外卡组特殊召唤。
-- 自己的仪式怪兽给与对方战斗伤害时：可以把自己墓地的这张卡除外；自己抽1张。
-- 「仪式的筹备」的每个效果1回合各能使用1次。
local s,id,o=GetID()
-- 初始化卡片效果：注册①卡组检索恶魔族仪式怪兽及衍生物特召效果、②墓地除外自身战斗伤害抽卡效果
function s.initial_effect(c)
	-- ①：从卡组把1只恶魔族仪式怪兽加入手卡，把灵摆怪兽加入手卡的场合，可以再在自己场上把1只「牺牲供物衍生物」（恶魔族·暗属性·1星·攻300/守300）特殊召唤。只要这衍生物在自己场上存在，自己不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCountLimit(1,id)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：自己的仪式怪兽给予对方战斗伤害时：可以把自己墓地的这张卡除外；自己抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"抽卡"
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetCountLimit(1,id+o)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCondition(s.drcon)
	-- ②效果发动Cost：将墓地的此卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
end
-- 卡组检索过滤条件：恶魔族仪式怪兽且可加入手牌
function s.thfilter(c)
	return c:IsAllTypes(TYPE_RITUAL+TYPE_MONSTER) and c:IsRace(RACE_FIEND) and c:IsAbleToHand()
end
-- ①效果发动准备：检查卡组是否存在符合条件的怪兽，并设置操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组是否存在可检索的恶魔族仪式怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息：从卡组检索1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理：从卡组检索恶魔族仪式怪兽，若检索灵摆怪兽可选择特殊召唤牺牲供物衍生物，并施加额外卡组特召限制
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要检索加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1只满足条件的恶魔族仪式怪兽
	local tc=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if tc then
		-- 将选中的怪兽从卡组加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的怪兽
		Duel.ConfirmCards(1-tp,tc)
		-- 检查加入手牌的怪兽是否为灵摆怪兽且场上有怪兽区域空位
		if tc:IsType(TYPE_PENDULUM) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 检查玩家是否具备特殊召唤「牺牲供物衍生物」的能力
			and Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,300,300,1,RACE_FIEND,ATTRIBUTE_DARK)
			-- 询问玩家是否选择特殊召唤衍生物
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否特殊召唤衍生物？"
			-- 中断当前效果，使随后的衍生物特殊召唤处理视为非同时处理
			Duel.BreakEffect()
			-- 生成1张「牺牲供物衍生物」
			local token=Duel.CreateToken(tp,id+o)
			-- 执行特殊召唤衍生物的第一阶段步骤
			Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
			-- 只要这衍生物在自己场上存在，自己不能从额外卡组特殊召唤。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e1:SetRange(LOCATION_MZONE)
			e1:SetAbsoluteRange(tp,1,0)
			e1:SetTarget(s.splimit)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_CONTROL)
			token:RegisterEffect(e1,true)
			-- 完成衍生物的特殊召唤程序
			Duel.SpecialSummonComplete()
		end
	end
end
-- 特殊召唤限制过滤条件：禁止从额外卡组特殊召唤
function s.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA)
end
-- ②效果触发条件：己方的仪式怪兽给予对方战斗伤害
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=eg:GetFirst()
	return ep~=tp and ec:IsControler(tp) and ec:IsAllTypes(TYPE_RITUAL+TYPE_MONSTER)
end
-- ②效果发动准备：设置己方抽1张卡的操作信息
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方玩家是否能够抽1张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置抽卡操作的目标玩家为己方
	Duel.SetTargetPlayer(tp)
	-- 设置抽卡操作的数量为1张
	Duel.SetTargetParam(1)
	-- 设置连锁操作信息：己方玩家抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- ②效果处理：己方抽1张卡
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取抽卡效果的目标玩家与抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 目标玩家从卡组抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
