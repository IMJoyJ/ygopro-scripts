--供物の下ごしらえ
-- 效果：
-- 从卡组把1只恶魔族仪式怪兽加入手卡，把灵摆怪兽加入手卡的场合，可以再在自己场上把1只「牺牲供物衍生物」（恶魔族·暗属性·1星·攻300/守300）特殊召唤。只要这衍生物在自己场上存在，自己不能从额外卡组特殊召唤。
-- 自己的仪式怪兽给与对方战斗伤害时：可以把自己墓地的这张卡除外；自己抽1张。
-- 「仪式的筹备」的每个效果1回合各能使用1次。
local s,id,o=GetID()
-- 初始化卡片效果：注册①卡片发动时检索恶魔族仪式怪兽并可选特召衍生物效果、②墓地除外抽卡效果
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
-- 卡组检索过滤条件：恶魔族的仪式怪兽且可加入手牌
function s.thfilter(c)
	return c:IsAllTypes(TYPE_RITUAL+TYPE_MONSTER) and c:IsRace(RACE_FIEND) and c:IsAbleToHand()
end
-- ①效果发动准备：检查卡组是否存在目标怪兽并设置检索操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：卡组中是否存在恶魔族仪式怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息：从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理：从卡组检索1只恶魔族仪式怪兽加入手牌，若加入的是灵摆怪兽且符合条件可特殊召唤1只衍生物并对其施加额外卡组特召限制
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1只恶魔族仪式怪兽
	local tc=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if tc then
		-- 将选中的怪兽加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,tc)
		-- 检查加入手牌的怪兽是否为灵摆怪兽且怪兽区域是否有空位
		if tc:IsType(TYPE_PENDULUM) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 检查玩家是否能特殊召唤符合特定属性和数值的衍生物
			and Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,300,300,1,RACE_FIEND,ATTRIBUTE_DARK)
			-- 询问玩家是否选择特殊召唤衍生物
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否特殊召唤衍生物？"
			-- 连接效果块（分隔检索加入手牌与特殊召唤衍生物的操作）
			Duel.BreakEffect()
			-- 创建1只「牺牲供物衍生物」
			local token=Duel.CreateToken(tp,id+o)
			-- 分步特殊召唤衍生物表侧表示到场上
			Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
			-- 给衍生物注册永续效果：只要此衍生物在场上存在，控制者不能从额外卡组特殊召唤怪兽
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
-- 额外卡组特召限制过滤：限制来源于额外卡组的特殊召唤
function s.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA)
end
-- ②效果触发条件：自己的仪式怪兽对对方造成战斗伤害时
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=eg:GetFirst()
	return ep~=tp and ec:IsControler(tp) and ec:IsAllTypes(TYPE_RITUAL+TYPE_MONSTER)
end
-- ②效果发动准备：检查是否能抽卡并设置抽卡操作信息与玩家目标
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：玩家是否可以抽1张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置效果目标玩家为自身
	Duel.SetTargetPlayer(tp)
	-- 设置效果目标参数为1（抽1张卡）
	Duel.SetTargetParam(1)
	-- 设置连锁操作信息：抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- ②效果处理：从卡组抽1张卡
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取目标玩家和抽卡数量参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 根据效果参数执行抽卡
	Duel.Draw(p,d,REASON_EFFECT)
end
