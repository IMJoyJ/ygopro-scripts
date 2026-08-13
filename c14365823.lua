--トリックスター・ディーヴァリディス
-- 效果：
-- 3星以下的「淘气仙星」怪兽2只
-- ①：「淘气仙星·蒂瓦丽迪丝」在自己场上只能有1只表侧表示存在。
-- ②：这张卡特殊召唤成功的场合才能发动。给与对方200伤害。
-- ③：每次对方对怪兽的召唤·特殊召唤成功发动。给与对方200伤害。
function c14365823.initial_effect(c)
	c:EnableReviveLimit()
	c:SetUniqueOnField(1,0,14365823)
	-- 为「淘气仙星·蒂瓦丽迪丝」添加连接召唤手续，要求以2只3星以下的「淘气仙星」怪兽作为连接素材。
	aux.AddLinkProcedure(c,c14365823.mfilter,2,2)
	-- ②：这张卡特殊召唤成功的场合才能发动。给与对方200伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(14365823,0))
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(c14365823.damtg)
	e1:SetOperation(c14365823.damop)
	c:RegisterEffect(e1)
	-- ③：每次对方对怪兽的召唤·特殊召唤成功发动。给与对方200伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(14365823,0))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c14365823.damcon2)
	e2:SetTarget(c14365823.damtg)
	e2:SetOperation(c14365823.damop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- mfilter为连接素材筛选条件：素材怪兽需为3星以下，且在作为连接素材时视为「淘气仙星」系列的怪兽。
function c14365823.mfilter(c)
	return c:IsLinkSetCard(0xfb) and c:IsLevelBelow(3)
end
-- damtg是效果的发动条件和目标设定函数：效果发动时可执行（chk==0返回true），并设定伤害对象为对方玩家、伤害值为200，同时登记伤害操作信息。
function c14365823.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的效果对象玩家设置为对方玩家（1-tp），即作为伤害承受者。
	Duel.SetTargetPlayer(1-tp)
	-- 将当前连锁的效果参数设为200，即后续要造成的伤害数值。
	Duel.SetTargetParam(200)
	-- 登记伤害效果的操作信息：宣布将对对方玩家造成200点伤害（分类为CATEGORY_DAMAGE），以便其他卡片进行响应或连锁。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,200)
end
-- damop是效果处理时的执行函数：从连锁中取得之前设定的对象玩家和伤害值，实际执行给与伤害。
function c14365823.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出对象玩家和参数，分别保存到变量p和d中。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因（REASON_EFFECT）对玩家p造成d点伤害，完成效果伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
-- cfilter过滤函数：用于判断怪兽c是由玩家tp召唤或特殊召唤的，用于检测对方是否进行了召唤。
function c14365823.cfilter(c,tp)
	return c:IsSummonPlayer(tp)
end
-- damcon2是③效果的发动条件：当本次召唤·特殊召唤成功的怪兽组中存在由对方玩家（1-tp）召唤的怪兽时，条件成立。
function c14365823.damcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c14365823.cfilter,1,nil,1-tp)
end
