--見えざる神ジャウザー
-- 效果：
-- 「不可见之手」怪兽＋幻想魔族怪兽
-- 这张卡用融合召唤以及以下方法才能从额外卡组特殊召唤。
-- ●把自己场上1只幻想魔族怪兽和1只原本持有者是对方的表侧表示怪兽解放的场合可以特殊召唤。这个卡名的①的效果1回合只能使用1次。
-- ①：自己主要阶段才能发动。从自己的卡组·墓地把1张「不可见之手」卡加入手卡。
-- ②：这张卡和怪兽进行战斗的场合，那2只不会被那次战斗破坏。
local s,id,o=GetID()
-- 注册卡片效果（融合召唤手续、特殊召唤规则、特殊召唤限制、①效果检索、②效果战斗不破）
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 设定融合素材为1只「不可见之手」怪兽和1只幻想魔族怪兽
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x1d3),aux.FilterBoolFunction(Card.IsRace,RACE_ILLUSION),true)
	-- ●把自己场上1只幻想魔族怪兽和1只原本持有者是对方的表侧表示怪兽解放的场合可以特殊召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetCondition(s.spcon)
	e0:SetTarget(s.sptg)
	e0:SetOperation(s.spop)
	c:RegisterEffect(e0)
	-- 这张卡用融合召唤以及以下方法才能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetRange(LOCATION_EXTRA)
	-- 限制该卡只能通过融合召唤或自身特殊召唤规则从额外卡组特殊召唤
	e1:SetValue(aux.fuslimit)
	c:RegisterEffect(e1)
	-- ①：自己主要阶段才能发动。从自己的卡组·墓地把1张「不可见之手」卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"检索效果"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- ②：这张卡和怪兽进行战斗的场合，那2只不会被那次战斗破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetTarget(s.indtg)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end
-- 过滤原本持有者是对方的表侧表示怪兽，且解放组中存在另一只幻想魔族怪兽
function s.cfilter(c,tp,g)
	return c:GetOwner()==1-tp and c:IsFaceup() and g:IsExists(Card.IsRace,1,c,RACE_ILLUSION)
end
-- 检查选取的2只怪兽是否满足特殊召唤的解放条件，且特殊召唤时额外卡组怪兽区域有空位
function s.fselect(g,tp,ec)
	-- 检查选取的卡片组中是否包含至少1只原本持有者是对方的表侧表示怪兽，且解放这些卡后有可用的额外怪兽区域
	return g:IsExists(s.cfilter,1,nil,tp,g) and Duel.GetLocationCountFromEx(tp,tp,g,ec)>0
end
-- 自身特殊召唤规则的条件函数：检查场上是否存在满足解放条件的怪兽组合
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取场上可作为特殊召唤素材解放的怪兽组
	local rg=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(Card.IsCanBeFusionMaterial,nil,c,SUMMON_TYPE_SPECIAL)
	return rg:CheckSubGroup(s.fselect,2,2,tp,c)
end
-- 自身特殊召唤规则的准备函数：让玩家选择并记录要解放的2只怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取场上可作为特殊召唤素材解放的怪兽组
	local rg=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(Card.IsCanBeFusionMaterial,nil,c,SUMMON_TYPE_SPECIAL)
	-- 提示玩家选择要解放的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local sg=rg:SelectSubGroup(tp,s.fselect,true,2,2,tp,c)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 自身特殊召唤规则的执行函数：将选定的怪兽作为素材解放，完成特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	c:SetMaterial(g)
	-- 解放选定的怪兽
	Duel.Release(g,REASON_SPSUMMON|REASON_MATERIAL)
	g:DeleteGroup()
end
-- 过滤卡组或墓地中可加入手牌的「不可见之手」卡片
function s.thfilter(c)
	return c:IsSetCard(0x1d3) and c:IsAbleToHand()
end
-- ①效果的发动准备：检查卡组或墓地是否存在可检索的卡，并设置检索操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组或墓地是否存在至少1张「不可见之手」卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置效果处理信息为从卡组或墓地将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- ①效果的执行函数：从卡组或墓地选择1张「不可见之手」卡加入手牌并给对方确认
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 过滤并选择1张不受王家长眠之谷影响的「不可见之手」卡
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		-- 将选取的卡片加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ②效果的过滤函数：确定不会被战斗破坏的怪兽为自身以及与自身进行战斗的怪兽
function s.indtg(e,c)
	local tc=e:GetHandler()
	return c==tc or c==tc:GetBattleTarget()
end
