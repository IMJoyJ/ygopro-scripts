--メガリス・オフィエル
-- 效果：
-- 「巨石遗物」卡降临
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡仪式召唤的场合才能发动。从卡组把「巨石遗物·奥菲尔」以外的1只「巨石遗物」怪兽加入手卡。
-- ②：自己主要阶段才能发动。等级合计直到变成仪式召唤的怪兽的等级以上为止，把包含场上的这张卡的自己的手卡·场上的怪兽解放，从手卡把1只仪式怪兽仪式召唤。
function c63056220.initial_effect(c)
	c:EnableReviveLimit()
	-- ①：这张卡仪式召唤的场合才能发动。从卡组把「巨石遗物·奥菲尔」以外的1只「巨石遗物」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(63056220,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(c63056220.srcon)
	e1:SetTarget(c63056220.srtg)
	e1:SetOperation(c63056220.srop)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段才能发动。等级合计直到变成仪式召唤的怪兽的等级以上为止，把包含场上的这张卡的自己的手卡·场上的怪兽解放，从手卡把1只仪式怪兽仪式召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(63056220,1))
	e2:SetCategory(CATEGORY_RELEASE+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,63056220)
	e2:SetTarget(c63056220.rstg)
	e2:SetOperation(c63056220.rsop)
	c:RegisterEffect(e2)
end
-- 判断此卡是否通过仪式召唤成功登场
function c63056220.srcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
-- 过滤卡组中除自身以外的「巨石遗物」怪兽
function c63056220.srfilter(c)
	return c:IsSetCard(0x138) and c:IsType(TYPE_MONSTER) and not c:IsCode(63056220) and c:IsAbleToHand()
end
-- 效果①的发动准备，检查卡组中是否存在可检索的怪兽并设置操作信息
function c63056220.srtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在符合条件的「巨石遗物」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c63056220.srfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：将卡组中的1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的效果处理：从卡组将1只符合条件的「巨石遗物」怪兽加入手卡
function c63056220.srop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张符合条件的「巨石遗物」怪兽
	local g=Duel.SelectMatchingCard(tp,c63056220.srfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 定义辅助检查函数，用于验证所选仪式素材中是否包含此卡
function c63056220.rcheck(gc)
	return	function(tp,g,c)
				return g:IsContains(gc)
			end
end
-- 效果②的发动准备，检查是否能以包含场上此卡的方式进行仪式召唤并设置操作信息
function c63056220.rstg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		-- 获取玩家当前可用的仪式召唤素材
		local mg=Duel.GetRitualMaterial(tp)
		-- 设置附加仪式检查，限定仪式素材必须包含此卡
		aux.RCheckAdditional=c63056220.rcheck(c)
		-- 检查可用素材中是否包含此卡，且手卡中是否存在可进行仪式召唤的仪式怪兽
		local res=mg:IsContains(c) and Duel.IsExistingMatchingCard(aux.RitualUltimateFilter,tp,LOCATION_HAND,0,1,nil,aux.TRUE,e,tp,mg,nil,Card.GetLevel,"Greater")
		-- 重置附加仪式检查函数
		aux.RCheckAdditional=nil
		return res
	end
	-- 设置操作信息：从手卡特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果②的效果处理：选择手卡的仪式怪兽，解放包含场上此卡的素材并进行仪式召唤
function c63056220.rsop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	::cancel::
	-- 获取当前可用的仪式召唤素材
	local mg=Duel.GetRitualMaterial(tp)
	if c:IsControler(1-tp) or not c:IsRelateToEffect(e) or not mg:IsContains(c) then return end
	-- 提示玩家选择要特殊召唤的仪式怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 设置附加仪式检查，限定仪式素材必须包含此卡
	aux.RCheckAdditional=c63056220.rcheck(c)
	-- 让玩家从手卡选择1只可以进行仪式召唤的仪式怪兽
	local tg=Duel.SelectMatchingCard(tp,aux.RitualUltimateFilter,tp,LOCATION_HAND,0,1,1,nil,aux.TRUE,e,tp,mg,nil,Card.GetLevel,"Greater")
	local tc=tg:GetFirst()
	if tc then
		mg=mg:Filter(Card.IsCanBeRitualMaterial,tc,tc)
		if tc.mat_filter then
			mg=mg:Filter(tc.mat_filter,tc,tp)
		else
		mg:RemoveCard(tc)
		end
		if not mg:IsContains(c) then return end
		-- 提示玩家选择要解放的仪式素材
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
		-- 预先选定此卡，强制其作为仪式素材的一部分
		Duel.SetSelectedCard(c)
		-- 设置组检查附加条件，用于验证素材等级合计是否达到仪式怪兽的等级以上
		aux.GCheckAdditional=aux.RitualCheckAdditional(tc,tc:GetLevel(),"Greater")
		-- 让玩家选择满足等级合计要求的仪式素材组合
		local mat=mg:SelectSubGroup(tp,aux.RitualCheck,true,1,tc:GetLevel(),tp,tc,tc:GetLevel(),"Greater")
		-- 重置组检查附加条件
		aux.GCheckAdditional=nil
		if not mat then
			-- 重置附加仪式检查函数，以便在取消选择时重新开始流程
			aux.RCheckAdditional=nil
			goto cancel
		end
		tc:SetMaterial(mat)
		-- 解放选定的仪式素材
		Duel.ReleaseRitualMaterial(mat)
		-- 中断当前效果处理，使之后的特殊召唤不与解放同时处理
		Duel.BreakEffect()
		-- 将选中的仪式怪兽以仪式召唤的方式特殊召唤
		Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
		tc:CompleteProcedure()
	end
	-- 重置附加仪式检查函数
	aux.RCheckAdditional=nil
end
