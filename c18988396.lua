--Miracle Raven
-- 效果：
-- ←0 【灵摆】 0→
-- 1回合1次，自己主要阶段：从自己的手卡·场上把等级合计直到1以上的怪兽解放，把这张卡仪式召唤。
-- 【怪兽效果】
-- 「奇迹的供物」降临。
-- 这张卡不用仪式召唤不能特殊召唤。
-- 仪式召唤的这张卡不受对方发动的效果影响。
-- 仪式怪兽1只仪式召唤的场合，可以用自己场上的这1张卡作为仪式召唤需要的数值的解放使用。
-- 这张卡为仪式召唤而解放的场合：可以从卡组把1只仪式怪兽加入手卡。「奇迹的供物」的这个效果1回合只能使用1次。
local s,id=GetID()
-- 初始化卡片效果，设置灵摆属性、仪式召唤条件、灵摆召唤效果、免疫效果、仪式等级调整和检索效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 为卡片添加灵摆属性，使其可以灵摆召唤
	aux.EnablePendulumAttribute(c)
	-- 这张卡不用仪式召唤不能特殊召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	-- 设置该卡必须通过仪式召唤方式特殊召唤
	e0:SetValue(aux.ritlimit)
	c:RegisterEffect(e0)
	-- 1回合1次，自己主要阶段：从自己的手卡·场上把等级合计直到1以上的怪兽解放，把这张卡仪式召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"这张卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.pztg)
	e1:SetOperation(s.pzop)
	c:RegisterEffect(e1)
	-- 仪式召唤的这张卡不受对方发动的效果影响。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.ritcon)
	e2:SetValue(s.efilter)
	c:RegisterEffect(e2)
	-- 仪式怪兽1只仪式召唤的场合，可以用自己场上的这1张卡作为仪式召唤需要的数值的解放使用。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_RITUAL_LEVEL)
	e3:SetValue(s.rlevel)
	c:RegisterEffect(e3)
	-- 这张卡为仪式召唤而解放的场合：可以从卡组把1只仪式怪兽加入手卡。「奇迹的供物」的这个效果1回合只能使用1次。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))  --"检索"
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_RELEASE)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,id)
	e4:SetCondition(s.thcon)
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)
end
-- 判断该卡是否为仪式召唤
function s.ritcon(e)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_RITUAL)
end
-- 过滤对方发动的效果，使其无法影响该卡
function s.efilter(e,te)
	return te:GetOwnerPlayer()~=e:GetHandlerPlayer() and te:IsActivated()
end
-- 设置该卡的仪式等级，用于仪式召唤时的等级计算
function s.rlevel(e,c)
	local ec=e:GetHandler()
	-- 获取该卡在系统安全阈值内的等级数值
	local lv=aux.GetCappedLevel(ec)
	if not ec:IsLocation(LOCATION_MZONE) then return lv end
	local clv=c:GetLevel()
	return (lv<<16)+clv
end
-- 判断该卡是否因仪式召唤而被解放
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_RITUAL)~=0
end
-- 检索过滤函数，用于筛选可加入手牌的仪式怪兽
function s.thfilter(c)
	return c:IsAllTypes(TYPE_RITUAL+TYPE_MONSTER) and c:IsAbleToHand()
end
-- 设置检索效果的处理信息，确定要检索的卡
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在满足条件的仪式怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置检索效果的处理信息，确定要检索的卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行检索效果，从卡组选择仪式怪兽加入手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 选择满足条件的仪式怪兽
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的仪式怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的仪式怪兽
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 设置灵摆召唤的处理信息，检查是否满足召唤条件
function s.pztg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		if not c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true) then return false end
		-- 获取玩家可用的仪式召唤素材
		local mg=Duel.GetRitualMaterial(tp)
		-- 设置仪式召唤的额外检查函数
		Auxiliary.GCheckAdditional=Auxiliary.RitualCheckAdditional(c,1,"Greater")
		-- 检查是否存在满足条件的仪式召唤组合
		local bool=mg:CheckSubGroup(Auxiliary.RitualCheck,1,1,tp,c,1,"Greater")
		-- 清除仪式召唤的额外检查函数
		Auxiliary.GCheckAdditional=nil
		return bool
	end
	-- 设置灵摆召唤的处理信息，确定召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,LOCATION_PZONE)
end
-- 执行灵摆召唤操作，选择并解放仪式召唤素材
function s.pzop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or not c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true) then return end
	-- 获取玩家可用的仪式召唤素材
	local mg=Duel.GetRitualMaterial(tp)
	-- 提示玩家选择要解放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 设置仪式召唤的额外检查函数
	Auxiliary.GCheckAdditional=Auxiliary.RitualCheckAdditional(c,1,"Greater")
	-- 选择满足条件的仪式召唤素材组合
	local mat=mg:SelectSubGroup(tp,Auxiliary.RitualCheck,true,1,1,tp,c,1,"Greater")
	-- 清除仪式召唤的额外检查函数
	Auxiliary.GCheckAdditional=nil
	if mat and mat:GetCount()>0 then
		c:SetMaterial(mat)
		-- 解放选中的仪式召唤素材
		Duel.ReleaseRitualMaterial(mat)
		-- 将该卡以仪式召唤方式特殊召唤到场上
		Duel.SpecialSummon(c,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
		c:CompleteProcedure()
	end
end
