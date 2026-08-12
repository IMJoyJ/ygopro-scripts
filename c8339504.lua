--エクシーズ・シフト
-- 效果：
-- 把自己场上1只超量怪兽解放才能发动。和解放的怪兽相同种族·属性·阶级而卡名不同的1只怪兽从额外卡组特殊召唤，把这张卡在下面重叠作为超量素材。这个效果特殊召唤的怪兽在结束阶段时送去墓地。「超量调换」在1回合只能发动1张。
function c8339504.initial_effect(c)
	-- 把自己场上1只超量怪兽解放才能发动。和解放的怪兽相同种族·属性·阶级而卡名不同的1只怪兽从额外卡组特殊召唤，把这张卡在下面重叠作为超量素材。这个效果特殊召唤的怪兽在结束阶段时送去墓地。「超量调换」在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,8339504+EFFECT_COUNT_CODE_OATH)
	e1:SetLabel(0)
	e1:SetCost(c8339504.cost)
	e1:SetTarget(c8339504.target)
	e1:SetOperation(c8339504.activate)
	c:RegisterEffect(e1)
end
-- 暂存发动代价检查标记，以便在target中进行解放处理
function c8339504.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return true end
end
-- 过滤自己场上可解放的、且额外卡组存在可特殊召唤的同种族·属性·阶级且卡名不同的怪兽的超量怪兽
function c8339504.cfilter(c,e,tp)
	local rk=c:GetRank()
	-- 检查额外卡组是否存在与该怪兽相同种族、属性、阶级且卡名不同的可特殊召唤怪兽
	return rk>0 and Duel.IsExistingMatchingCard(c8339504.spfilter1,tp,LOCATION_EXTRA,0,1,nil,rk,c:GetRace(),c:GetAttribute(),c:GetCode(),e,tp,c)
end
-- 过滤额外卡组中满足相同种族、属性、阶级且卡名不同，且能特殊召唤到额外怪兽区域或所指向区域的怪兽
function c8339504.spfilter1(c,rk,race,att,code,e,tp,mc)
	return c:IsRank(rk) and c:IsRace(race) and c:IsAttribute(att)
		-- 检查卡名不同、可以特殊召唤，且在解放该怪兽后额外卡组怪兽有可用的特殊召唤位置
		and not c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 效果发动时的目标选择与代价支付处理（检查并选择要解放的怪兽，将其解放，并保存其属性信息，设置特殊召唤的操作信息）
function c8339504.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		return e:IsHasType(EFFECT_TYPE_ACTIVATE)
			and e:GetHandler():IsCanOverlay()
			-- 检查自己场上是否存在至少1只满足条件的、可解放的超量怪兽
			and Duel.CheckReleaseGroup(tp,c8339504.cfilter,1,nil,e,tp)
	end
	e:SetLabel(0)
	-- 玩家选择1只满足条件的超量怪兽解放
	local g=Duel.SelectReleaseGroup(tp,c8339504.cfilter,1,1,nil,e,tp)
	e:SetLabel(g:GetFirst():GetRank(),g:GetFirst():GetRace(),g:GetFirst():GetAttribute(),g:GetFirst():GetCode())
	-- 将选择的怪兽解放作为发动的代价
	Duel.Release(g,REASON_COST)
	-- 设置特殊召唤的操作信息（从额外卡组特殊召唤1只怪兽）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理的核心逻辑（特殊召唤符合条件的怪兽，将此卡叠放作为其超量素材，并注册结束阶段送去墓地的效果）
function c8339504.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rk,race,att,code=e:GetLabel()
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组选择1只与解放怪兽相同种族·属性·阶级且卡名不同的怪兽
	local g=Duel.SelectMatchingCard(tp,c8339504.spfilter1,tp,LOCATION_EXTRA,0,1,1,nil,rk,race,att,code,e,tp,nil)
	local sc=g:GetFirst()
	-- 将选择的怪兽以表侧表示特殊召唤，并判断是否特殊召唤成功
	if sc and Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		if c:IsRelateToEffect(e) then
			c:CancelToGrave()
			-- 将这张卡重叠在特殊召唤的怪兽下面作为超量素材
			Duel.Overlay(sc,Group.FromCards(c))
		end
		local fid=c:GetFieldID()
		sc:RegisterFlagEffect(8339504,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		-- 这个效果特殊召唤的怪兽在结束阶段时送去墓地。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetLabel(fid)
		e1:SetLabelObject(sc)
		e1:SetCondition(c8339504.tgcon)
		e1:SetOperation(c8339504.tgop)
		-- 注册在结束阶段将特殊召唤的怪兽送去墓地的全局延迟效果
		Duel.RegisterEffect(e1,tp)
	end
end
-- 检查特殊召唤的怪兽是否仍在场上且标记未失效，若失效则重置该效果
function c8339504.tgcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(8339504)~=e:GetLabel() then
		e:Reset()
		return false
	else return true end
end
-- 结束阶段时，将特殊召唤的怪兽送去墓地的具体操作
function c8339504.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 因效果将特殊召唤的怪兽送去墓地
	Duel.SendtoGrave(e:GetLabelObject(),REASON_EFFECT)
end
