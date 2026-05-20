--覇王眷竜クリアウィング
-- 效果：
-- 调整＋调整以外的暗属性灵摆怪兽1只以上
-- ①：这张卡同调召唤的场合才能发动。对方场上的表侧表示怪兽全部破坏。
-- ②：1回合1次，这张卡和对方怪兽进行战斗的伤害计算前才能发动。那只怪兽破坏，给与对方破坏的怪兽的原本攻击力数值的伤害。
-- ③：这张卡在墓地存在的场合，把自己场上2只「霸王眷龙」怪兽解放才能发动。这张卡特殊召唤。
function c70771599.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加同调召唤手续：需要1只调整怪兽，以及1只以上满足过滤条件（暗属性灵摆怪兽）的非调整怪兽
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(c70771599.matfilter),1)
	-- ①：这张卡同调召唤的场合才能发动。对方场上的表侧表示怪兽全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(70771599,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(c70771599.descon)
	e1:SetTarget(c70771599.destg)
	e1:SetOperation(c70771599.desop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，这张卡和对方怪兽进行战斗的伤害计算前才能发动。那只怪兽破坏，给与对方破坏的怪兽的原本攻击力数值的伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(70771599,1))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_CONFIRM)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCountLimit(1)
	e2:SetCondition(c70771599.ddcon)
	e2:SetTarget(c70771599.ddtg)
	e2:SetOperation(c70771599.ddop)
	c:RegisterEffect(e2)
	-- ③：这张卡在墓地存在的场合，把自己场上2只「霸王眷龙」怪兽解放才能发动。这张卡特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(70771599,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCost(c70771599.spcost)
	e3:SetTarget(c70771599.sptg)
	e3:SetOperation(c70771599.spop)
	c:RegisterEffect(e3)
end
-- 过滤同调素材中的非调整怪兽：必须是暗属性且是灵摆怪兽
function c70771599.matfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsType(TYPE_PENDULUM)
end
-- 效果①的发动条件：这张卡是通过同调召唤特殊召唤成功的
function c70771599.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 效果①的发动检测：检查对方场上是否存在表侧表示的怪兽，并设置破坏操作信息
function c70771599.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方场上所有表侧表示的怪兽
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	if chk==0 then return g:GetCount()>0 end
	-- 设置当前连锁的操作信息为：破坏对方场上所有的表侧表示怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果①的效果处理：获取对方场上表侧表示的怪兽并将其全部破坏
function c70771599.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有表侧表示的怪兽
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		-- 因效果破坏获取到的怪兽组
		Duel.Destroy(g,REASON_EFFECT)
	end
end
-- 效果②的发动条件：这张卡和对方怪兽进行战斗，且双方怪兽在伤害计算前都表侧表示存在于场上并处于战斗状态
function c70771599.ddcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:IsRelateToBattle() and bc and bc:IsFaceup() and bc:IsRelateToBattle()
end
-- 效果②的发动检测：获取进行战斗的对方怪兽，设置对方玩家为效果对象玩家，并设置破坏该怪兽及给与对方其原本攻击力数值伤害的操作信息
function c70771599.ddtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local bc=e:GetHandler():GetBattleTarget()
	-- 将当前连锁的对象玩家设置为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 设置当前连锁的操作信息为：破坏进行战斗的对方怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,bc,1,0,0)
	-- 设置当前连锁的操作信息为：给与对方玩家该怪兽原本攻击力数值的伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,bc:GetBaseAttack())
end
-- 效果②的效果处理：确认双方怪兽仍处于战斗状态后，破坏对方怪兽，并给与对方该怪兽原本攻击力数值的伤害
function c70771599.ddop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	-- 获取当前连锁设定的对象玩家（即对方玩家）
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 确认自身和对方怪兽均表侧表示且处于战斗状态，并成功因效果破坏对方怪兽
	if c:IsFaceup() and c:IsRelateToBattle() and bc:IsFaceup() and bc:IsRelateToBattle() and Duel.Destroy(bc,REASON_EFFECT)>0 then
		local dam=bc:GetBaseAttack()
		-- 若被破坏怪兽的原本攻击力大于0，则给与对方玩家该数值的效果伤害
		if dam>0 then Duel.Damage(p,dam,REASON_EFFECT) end
	end
end
-- 效果③的发动代价：检查并从自己场上选择2只「霸王眷龙」怪兽解放
function c70771599.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在2只可解放的「霸王眷龙」怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsSetCard,2,nil,0x20f8) end
	-- 选出自己场上2只「霸王眷龙」怪兽
	local g=Duel.SelectReleaseGroup(tp,Card.IsSetCard,2,2,nil,0x20f8)
	-- 解放选出的怪兽作为发动的代价
	Duel.Release(g,REASON_COST)
end
-- 效果③的发动检测：检查怪兽区域空位数是否足够，以及自身是否能特殊召唤，并设置特殊召唤的操作信息
function c70771599.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查怪兽区域空位数（由于解放了2只怪兽，空位数需大于-2）以及自身是否可以特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-2 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置当前连锁的操作信息为：将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果③的效果处理：若怪兽区域有空位且自身仍存在于墓地，则将自身表侧表示特殊召唤
function c70771599.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认自己场上有可用的怪兽区域空格，且自身卡片与效果相关联（仍在墓地）
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsRelateToEffect(e) then
		-- 将自身以表侧表示特殊召唤到自己的场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
