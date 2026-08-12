--幻獣ロックリザード
-- 效果：
-- 把名字带有「幻兽」的怪兽作为祭品的场合，这张卡可以用1只祭品作召唤。这张卡每战斗破坏1只怪兽，给与对方基本分500分伤害。对方控制的卡效果把这张卡破坏送去墓地时，给与对方基本分2000分伤害。
function c70969517.initial_effect(c)
	-- 把名字带有「幻兽」的怪兽作为祭品的场合，这张卡可以用1只祭品作召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(70969517,0))  --"用1只怪兽解放上级召唤"
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c70969517.otcon)
	e1:SetOperation(c70969517.otop)
	e1:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e1)
	-- 这张卡每战斗破坏1只怪兽，给与对方基本分500分伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(70969517,1))  --"给予对方500伤害"
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetTarget(c70969517.damtg1)
	e2:SetOperation(c70969517.damop)
	c:RegisterEffect(e2)
	-- 对方控制的卡效果把这张卡破坏送去墓地时，给与对方基本分2000分伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(70969517,2))  --"给予对方2000伤害"
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c70969517.damcon2)
	e2:SetTarget(c70969517.damtg2)
	e2:SetOperation(c70969517.damop)
	c:RegisterEffect(e2)
end
-- 过滤场上属于自己控制或在对方场上表侧表示的名字带有「幻兽」的怪兽
function c70969517.otfilter(c,tp)
	return c:IsSetCard(0x1b) and (c:IsControler(tp) or c:IsFaceup())
end
-- 判断是否满足用1只「幻兽」怪兽作为祭品进行上级召唤的条件
function c70969517.otcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取场上所有满足「幻兽」怪兽过滤条件的卡片组
	local mg=Duel.GetMatchingGroup(c70969517.otfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 判断这张卡是否为7星以上、所需最少祭品数小于等于1，且场上存在至少1只满足条件的「幻兽」怪兽作为祭品
	return c:IsLevelAbove(7) and minc<=1 and Duel.CheckTribute(c,1,1,mg)
end
-- 执行用1只「幻兽」怪兽作为祭品进行上级召唤的具体操作
function c70969517.otop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 获取场上所有满足「幻兽」怪兽过滤条件的卡片组
	local mg=Duel.GetMatchingGroup(c70969517.otfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 让玩家从满足条件的卡片组中选择1只怪兽作为祭品
	local sg=Duel.SelectTribute(tp,c,1,1,mg)
	c:SetMaterial(sg)
	-- 解放选中的怪兽，作为上级召唤的祭品
	Duel.Release(sg,REASON_SUMMON+REASON_MATERIAL)
end
-- 设置战斗破坏伤害效果的对象玩家为对方，伤害数值为500
function c70969517.damtg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将效果的对象玩家设置为对方
	Duel.SetTargetPlayer(1-tp)
	-- 将效果的对象参数（伤害数值）设置为500
	Duel.SetTargetParam(500)
	-- 设置连锁的操作信息，表示该效果会给与对方500点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
-- 判断是否是由对方控制的卡的效果将这张卡破坏并送去墓地
function c70969517.damcon2(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,0x41)==0x41 and rp==1-tp and e:GetHandler():IsPreviousControler(tp)
end
-- 设置破坏送墓伤害效果的对象玩家为对方，伤害数值为2000
function c70969517.damtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将效果的对象玩家设置为对方
	Duel.SetTargetPlayer(1-tp)
	-- 将效果的对象参数（伤害数值）设置为2000
	Duel.SetTargetParam(2000)
	-- 设置连锁的操作信息，表示该效果会给与对方2000点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,2000)
end
-- 获取连锁信息并给与对方相应的基本分伤害
function c70969517.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的目标玩家和伤害数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果伤害的形式给与目标玩家对应的伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
