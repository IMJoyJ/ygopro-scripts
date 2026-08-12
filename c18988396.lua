--ミラクル・レイヴン－供物の儀式－
-- 效果：
-- ←0 【灵摆】 0→
-- ①：1回合1次，自己主要阶段才能发动。等级合计直到1以上的自己的手卡·场上的怪兽解放，把这张卡仪式召唤。
-- 【怪兽效果】
-- 「奇迹之供物-供物的仪式-」降临
-- 这张卡不用仪式召唤不能特殊召唤。这个卡名的③的怪兽效果1回合只能使用1次。
-- ①：仪式召唤的这张卡不受对方发动的效果影响。
-- ②：仪式怪兽1只仪式召唤的场合，可以由自己场上的这1张卡作为仪式召唤需要的数值的解放使用。
-- ③：这张卡为仪式召唤而被解放的场合才能发动。从卡组把1只仪式怪兽加入手卡。
local s,id=GetID()
-- 初始化卡片效果：设置苏生限制、赋予灵摆属性，并依次注册特殊召唤条件、灵摆区的仪式召唤起动效果、怪兽区的效果免疫、作为仪式素材时的等级计算以及被解放时的卡组检索诱发效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡赋予灵摆怪兽属性，使其可以进行灵摆召唤和作为灵摆卡发动
	aux.EnablePendulumAttribute(c)
	-- 这张卡不用仪式召唤不能特殊召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	-- 设置特殊召唤条件的判定值：只能用仪式召唤的方式特殊召唤这张卡
	e0:SetValue(aux.ritlimit)
	c:RegisterEffect(e0)
	-- ①：1回合1次，自己主要阶段才能发动。等级合计直到1以上的自己的手卡·场上的怪兽解放，把这张卡仪式召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"这张卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.pztg)
	e1:SetOperation(s.pzop)
	c:RegisterEffect(e1)
	-- ①：仪式召唤的这张卡不受对方发动的效果影响。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.ritcon)
	e2:SetValue(s.efilter)
	c:RegisterEffect(e2)
	-- ②：仪式怪兽1只仪式召唤的场合，可以由自己场上的这1张卡作为仪式召唤需要的数值的解放使用。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_RITUAL_LEVEL)
	e3:SetValue(s.rlevel)
	c:RegisterEffect(e3)
	-- ③：这张卡为仪式召唤而被解放的场合才能发动。从卡组把1只仪式怪兽加入手卡。
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
-- 效果免疫的适用条件：这张卡是仪式召唤的场合才适用
function s.ritcon(e)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_RITUAL)
end
-- 免疫的过滤条件：只免疫对方玩家发动的效果，自己发动的效果不受影响
function s.efilter(e,te)
	return te:GetOwnerPlayer()~=e:GetHandlerPlayer() and te:IsActivated()
end
-- 计算这张卡作为仪式素材时的等级：不在怪兽区时返回自身等级；在怪兽区时返回与仪式怪兽等级打包后的数值，使这1张卡即可作为仪式召唤需要的全部解放
function s.rlevel(e,c)
	local ec=e:GetHandler()
	-- 获取这张卡的等级（限制在系统安全上限内，防止数值溢出）
	local lv=aux.GetCappedLevel(ec)
	if not ec:IsLocation(LOCATION_MZONE) then return lv end
	local clv=c:GetLevel()
	return (lv<<16)+clv
end
-- 检索效果的发动条件：这张卡是因为仪式召唤而被解放的场合
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_RITUAL)~=0
end
-- 检索对象的过滤条件：是可以加入手卡的仪式怪兽
function s.thfilter(c)
	return c:IsAllTypes(TYPE_RITUAL+TYPE_MONSTER) and c:IsAbleToHand()
end
-- 检索效果的目标设定：确认卡组存在可加入手卡的仪式怪兽，并设置回手牌的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果可发动检查：自己卡组存在至少1只可以加入手卡的仪式怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：将从卡组把1张卡加入手卡（具体卡在处理时确定）
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的处理：从卡组选1只仪式怪兽加入手卡，并向对方确认
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 让自己从卡组选择1只可以加入手卡的仪式怪兽
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 把选择的仪式怪兽以效果处理加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 灵摆效果的目标设定：检查这张卡能否仪式召唤（是否可特殊召唤且素材中存在等级合计1以上的合法组合），并设置特殊召唤的操作信息
function s.pztg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		if not c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true) then return false end
		-- 获取自己可用的仪式召唤素材（手卡、场上可解放的怪兽等）
		local mg=Duel.GetRitualMaterial(tp)
		-- 设置额外素材检查：按等级合计可以大于等于1的方式来判定素材组合的合理性
		Auxiliary.GCheckAdditional=Auxiliary.RitualCheckAdditional(c,1,"Greater")
		-- 检查素材组中是否存在等级合计1以上、可以把这张卡仪式召唤的合法素材组合
		local bool=mg:CheckSubGroup(Auxiliary.RitualCheck,1,1,tp,c,1,"Greater")
		-- 清除额外素材检查的临时设置
		Auxiliary.GCheckAdditional=nil
		return bool
	end
	-- 设置操作信息：将把灵摆区的这张卡仪式召唤（特殊召唤）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,LOCATION_PZONE)
end
-- 灵摆效果的处理：确认这张卡仍可仪式召唤后，让玩家选择等级合计1以上的解放素材，解放素材并把这张卡仪式召唤
function s.pzop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or not c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true) then return end
	-- 获取自己可用的仪式召唤素材（手卡、场上可解放的怪兽等）
	local mg=Duel.GetRitualMaterial(tp)
	-- 提示玩家选择要解放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 设置额外素材检查：按等级合计可以大于等于1的方式来判定素材组合的合理性
	Auxiliary.GCheckAdditional=Auxiliary.RitualCheckAdditional(c,1,"Greater")
	-- 让玩家从素材中选择1组等级合计1以上、可以把这张卡仪式召唤的合法解放素材
	local mat=mg:SelectSubGroup(tp,Auxiliary.RitualCheck,true,1,1,tp,c,1,"Greater")
	-- 清除额外素材检查的临时设置
	Auxiliary.GCheckAdditional=nil
	if mat and mat:GetCount()>0 then
		c:SetMaterial(mat)
		-- 解放选定的仪式素材
		Duel.ReleaseRitualMaterial(mat)
		-- 把这张卡以仪式召唤方式表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(c,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
		c:CompleteProcedure()
	end
end
