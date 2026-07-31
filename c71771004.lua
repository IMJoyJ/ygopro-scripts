--供物の下ごしらえ
-- 效果：
-- 从卡组把1只恶魔族仪式怪兽加入手卡，把灵摆怪兽加入手卡的场合，可以再在自己场上把1只「牺牲供物衍生物」（恶魔族·暗属性·1星·攻300/守300）特殊召唤。只要这衍生物在自己场上存在，自己不能从额外卡组特殊召唤。
-- 自己的仪式怪兽给与对方战斗伤害时：可以把自己墓地的这张卡除外；自己抽1张。
-- 「仪式的筹备」的每个效果1回合各能使用1次。
local s,id,o=GetID()
-- 初始化卡片效果：注册①检索恶魔族仪式怪兽（可衍生特召衍生物）效果、②仪式怪兽造成战伤除外墓地自身抽卡效果
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
	-- ②效果发动Cost：把墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
end
-- 检索对象过滤：卡组中的恶魔族仪式怪兽
function s.thfilter(c)
	return c:IsAllTypes(TYPE_RITUAL+TYPE_MONSTER) and c:IsRace(RACE_FIEND) and c:IsAbleToHand()
end
-- ①效果发动准备：检查卡组检索目标并设置加入手牌的操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：卡组是否存在恶魔族仪式怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息：从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理：从卡组检索1只恶魔族仪式怪兽加入手牌，若为灵摆怪兽可选择特召1只牺牲供物衍生物并施加额外卡组特召限制
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1只恶魔族仪式怪兽
	local tc=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if tc then
		-- 将选中的怪兽加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,tc)
		-- 检查加入手牌的卡是否为灵摆怪兽且怪兽区域有空位
		if tc:IsType(TYPE_PENDULUM) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 检查玩家是否可以特殊召唤牺牲供物衍生物
			and Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,300,300,1,RACE_FIEND,ATTRIBUTE_DARK)
			-- 询问玩家是否选择特殊召唤衍生物
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否特殊召唤衍生物？"
			-- 分隔效果处理步骤
			Duel.BreakEffect()
			-- 创建牺牲供物衍生物 Token
			local token=Duel.CreateToken(tp,id+o)
			-- 分步表侧表示特殊召唤衍生物
			Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
			-- 牺牲供物衍生物在场存在时，玩家不能从额外卡组特殊召唤的持续效果
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e1:SetRange(LOCATION_MZONE)
			e1:SetAbsoluteRange(tp,1,0)
			e1:SetTarget(s.splimit)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_CONTROL)
			token:RegisterEffect(e1,true)
			-- 完成衍生物的特殊召唤
			Duel.SpecialSummonComplete()
		end
	end
end
-- 特召限制过滤：限制不能从额外卡组特殊召唤
function s.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA)
end
-- ②效果发动条件：自己的仪式怪兽给予对方战斗伤害
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=eg:GetFirst()
	return ep~=tp and ec:IsControler(tp) and ec:IsAllTypes(TYPE_RITUAL+TYPE_MONSTER)
end
-- ②效果发动准备：设置抽卡玩家与抽卡数量的操作信息
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：玩家是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置抽卡效果的目标玩家为自身
	Duel.SetTargetPlayer(tp)
	-- 设置抽卡数量为1张
	Duel.SetTargetParam(1)
	-- 设置连锁操作信息：抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- ②效果处理：抽1张卡
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取目标玩家与抽卡张数参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 目标玩家因效果抽卡
	Duel.Draw(p,d,REASON_EFFECT)
end
