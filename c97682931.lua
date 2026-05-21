--レボリューション・シンクロン
--not fully implemented
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次，②的效果在决斗中只能使用1次。
-- ①：「动力工具」同调怪兽或者7·8星的龙族同调怪兽同调召唤的场合，手卡的这张卡也能作为同调素材。
-- ②：这张卡在墓地存在，自己场上有7星以上的同调怪兽存在的场合才能发动。自己卡组最上面的卡送去墓地，这张卡特殊召唤。这个效果特殊召唤的这张卡的等级变成1星。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含手卡同调素材效果、使用次数限制辅助效果以及墓地特殊召唤效果。
function s.initial_effect(c)
	-- 「动力工具」同调怪兽或者7·8星的龙族同调怪兽同调召唤的场合，手卡的这张卡也能作为同调素材。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EXTRA_SYNCHRO_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetValue(s.matval)
	c:RegisterEffect(e1)
	-- 这个卡名的①的效果1回合只能使用1次
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_BE_PRE_MATERIAL)
	e0:SetProperty(EFFECT_FLAG_EVENT_PLAYER+EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetLabelObject(e1)
	e0:SetCondition(s.hsyncon)
	e0:SetOperation(s.hsynreg)
	c:RegisterEffect(e0)
	-- 这张卡在墓地存在，自己场上有7星以上的同调怪兽存在的场合才能发动。自己卡组最上面的卡送去墓地，这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DECKDES+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+1+EFFECT_COUNT_CODE_DUEL)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 过滤作为同调素材的目标怪兽，必须是同调怪兽且为7·8星龙族或「动力工具」怪兽。
function s.matval(e,c)
	return c:IsType(TYPE_SYNCHRO) and (c:IsLevel(7,8) and c:IsRace(RACE_DRAGON) or c:IsSetCard(0xc2))
end
-- 检查是否是作为符合条件的同调怪兽的同调素材，且之前的位置是在手卡。
function s.hsyncon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return r==REASON_SYNCHRO and s.matval(nil,c:GetReasonCard()) and c:IsPreviousLocation(LOCATION_HAND)
end
-- 消耗手卡同调素材效果（e1）的1回合1次使用次数限制。
function s.hsynreg(e,tp,eg,ep,ev,re,r,rp)
	e:GetLabelObject():UseCountLimit(tp)
end
-- 过滤自己场上表侧表示的7星以上的同调怪兽。
function s.cfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(7) and c:IsType(TYPE_SYNCHRO)
end
-- 墓地特召效果的发动条件：自己场上存在7星以上的同调怪兽。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只表侧表示的7星以上的同调怪兽。
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 墓地特召效果的发动准备与合法性检查（检查卡组是否能送墓、怪兽区域是否有空位、自身是否能特殊召唤）。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查玩家是否能将卡组最上面的1张卡送去墓地。
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1)
		-- 检查自己场上是否有空余的怪兽区域，且这张卡是否可以特殊召唤。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁操作信息：包含从卡组送去墓地的效果，数量为1张。
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,1)
	-- 设置连锁操作信息：包含特殊召唤自身的效果。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 墓地特召效果的处理：将卡组最上面的卡送去墓地，若成功则将自身特殊召唤，并将其等级变成1星。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 执行将自己卡组最上面的1张卡送去墓地的操作，并检查是否成功送墓。
	if Duel.DiscardDeck(tp,1,REASON_EFFECT)~=0 then
		-- 获取刚刚被送去墓地的卡片。
		local oc=Duel.GetOperatedGroup():GetFirst()
		local c=e:GetHandler()
		if oc:IsLocation(LOCATION_GRAVE) and c:IsRelateToEffect(e)
			-- 尝试将这张卡以表侧表示特殊召唤到自己场上（分步特召处理）。
			and Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
			-- 这个效果特殊召唤的这张卡的等级变成1星。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_LEVEL)
			e1:SetValue(1)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			c:RegisterEffect(e1,true)
		end
		-- 完成特殊召唤的最终处理，使特召的怪兽正式出场。
		Duel.SpecialSummonComplete()
	end
end
