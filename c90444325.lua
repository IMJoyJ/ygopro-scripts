--メガリス・ハギト
-- 效果：
-- 「巨石遗物」卡降临。这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡仪式召唤成功的场合才能发动。从卡组把1张「巨石遗物」魔法·陷阱卡加入手卡。
-- ②：自己主要阶段才能发动。等级合计直到变成仪式召唤的怪兽的等级以上为止，把包含场上的这张卡的自己的手卡·场上的怪兽解放，从手卡把1只仪式怪兽仪式召唤。
function c90444325.initial_effect(c)
	c:EnableReviveLimit()
	-- ①：这张卡仪式召唤成功的场合才能发动。从卡组把1张「巨石遗物」魔法·陷阱卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(90444325,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(c90444325.srcon)
	e1:SetTarget(c90444325.srtg)
	e1:SetOperation(c90444325.srop)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段才能发动。等级合计直到变成仪式召唤的怪兽的等级以上为止，把包含场上的这张卡的自己的手卡·场上的怪兽解放，从手卡把1只仪式怪兽仪式召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(90444325,1))
	e2:SetCategory(CATEGORY_RELEASE+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,90444325)
	e2:SetTarget(c90444325.rstg)
	e2:SetOperation(c90444325.rsop)
	c:RegisterEffect(e2)
end
-- 过滤条件：卡组中的「巨石遗物」魔法·陷阱卡
function c90444325.srfilter(c)
	return c:IsSetCard(0x138) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 发动条件：这张卡仪式召唤成功
function c90444325.srcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
-- 效果①的发动准备（检查卡组是否存在可检索卡并设置操作信息）
function c90444325.srtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 步骤1的检查：检查卡组中是否存在可以加入手牌的「巨石遗物」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c90444325.srfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁中的操作信息：从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的处理（从卡组选择1张「巨石遗物」魔法·陷阱卡加入手牌）
function c90444325.srop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家发送提示信息：选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足过滤条件的「巨石遗物」魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,c90444325.srfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡因效果加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 辅助检查函数：用于确保仪式召唤的素材中必须包含指定的卡（即场上的这张卡）
function c90444325.rcheck(gc)
	return	function(tp,g,c)
				return g:IsContains(gc)
			end
end
-- 效果②的发动准备（检查是否能进行包含场上此卡的仪式召唤并设置操作信息）
function c90444325.rstg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		-- 获取玩家当前可用的仪式素材卡片组
		local mg=Duel.GetRitualMaterial(tp)
		-- 设置全局附加检查函数，限定仪式素材必须包含场上的这张卡
		aux.RCheckAdditional=c90444325.rcheck(c)
		-- 检查当前可用的仪式素材是否包含这张卡，且手牌中是否存在可进行仪式召唤的仪式怪兽
		local res=mg:IsContains(c) and Duel.IsExistingMatchingCard(aux.RitualUltimateFilter,tp,LOCATION_HAND,0,1,nil,aux.TRUE,e,tp,mg,nil,Card.GetLevel,"Greater")
		-- 重置全局附加检查函数
		aux.RCheckAdditional=nil
		return res
	end
	-- 设置连锁中的操作信息：从手牌特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果②的处理（选择手牌的仪式怪兽，并解放包含场上此卡的素材进行仪式召唤）
function c90444325.rsop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	::cancel::
	-- 获取玩家当前可用的仪式素材卡片组
	local mg=Duel.GetRitualMaterial(tp)
	if c:IsControler(1-tp) or not c:IsRelateToEffect(e) or not mg:IsContains(c) then return end
	-- 给玩家发送提示信息：选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 设置全局附加检查函数，限定仪式素材必须包含场上的这张卡
	aux.RCheckAdditional=c90444325.rcheck(c)
	-- 让玩家从手牌选择1只可以进行仪式召唤的仪式怪兽
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
		-- 给玩家发送提示信息：选择要解放的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
		-- 预先设定场上的这张卡为必须选择的仪式素材
		Duel.SetSelectedCard(c)
		-- 设置全局组检查函数，用于验证所选素材的等级合计是否达到仪式怪兽的等级以上
		aux.GCheckAdditional=aux.RitualCheckAdditional(tc,tc:GetLevel(),"Greater")
		-- 让玩家选择满足仪式召唤条件的素材怪兽组
		local mat=mg:SelectSubGroup(tp,aux.RitualCheck,true,1,tc:GetLevel(),tp,tc,tc:GetLevel(),"Greater")
		-- 重置全局组检查函数
		aux.GCheckAdditional=nil
		if not mat then
			-- 重置全局附加检查函数
			aux.RCheckAdditional=nil
			goto cancel
		end
		tc:SetMaterial(mat)
		-- 解放选定的仪式素材怪兽
		Duel.ReleaseRitualMaterial(mat)
		-- 中断当前效果处理，使后续的特殊召唤不与解放同时处理
		Duel.BreakEffect()
		-- 将选定的仪式怪兽以仪式召唤的方式表侧表示特殊召唤
		Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
		tc:CompleteProcedure()
	end
	-- 重置全局附加检查函数（安全清理）
	aux.RCheckAdditional=nil
end
