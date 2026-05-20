--ヴァリアンツG－グランデューク
-- 效果：
-- ←10 【灵摆】 10→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：可以从以下效果选择1个发动。
-- ●这张卡在正对面的自己的主要怪兽区域特殊召唤。
-- ●选自己的主要怪兽区域1只怪兽，那个位置向那个相邻的怪兽区域移动。
-- 【怪兽效果】
-- 「群豪」怪兽×2
-- 额外卡组的里侧表示的这张卡用融合召唤以及以下方法才能特殊召唤。
-- ●把除融合怪兽外的和额外怪兽区域相同纵列1只自己的5星以上的「群豪」怪兽解放的场合可以特殊召唤。
-- ①：这张卡特殊召唤成功的场合，以对方的魔法与陷阱区域1张怪兽卡为对象才能发动。那张卡回到持有者手卡，给与对方那个攻击力数值的伤害。那之后，这张卡的攻击力上升给与的伤害一半数值。
function c76075139.initial_effect(c)
	c:EnableReviveLimit()
	-- 注册融合召唤素材：2只「群豪」怪兽。
	aux.AddFusionProcFunRep(c,c76075139.ffilter,2,true)
	-- 注册灵摆怪兽属性（不注册灵摆卡卡的发动效果）。
	aux.EnablePendulumAttribute(c,false)
	-- 额外卡组的里侧表示的这张卡用融合召唤以及以下方法才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c76075139.splimit)
	c:RegisterEffect(e1)
	-- ●把除融合怪兽外的和额外怪兽区域相同纵列1只自己的5星以上的「群豪」怪兽解放的场合可以特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetCondition(c76075139.hspcon)
	e2:SetTarget(c76075139.hsptg)
	e2:SetOperation(c76075139.hspop)
	c:RegisterEffect(e2)
	-- ①：可以从以下效果选择1个发动。●这张卡在正对面的自己的主要怪兽区域特殊召唤。●选自己的主要怪兽区域1只怪兽，那个位置向那个相邻的怪兽区域移动。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_PZONE)
	e3:SetCountLimit(1,76075139)
	e3:SetTarget(c76075139.ptg)
	e3:SetOperation(c76075139.pop)
	c:RegisterEffect(e3)
	-- ①：这张卡特殊召唤成功的场合，以对方的魔法与陷阱区域1张怪兽卡为对象才能发动。那张卡回到持有者手卡，给与对方那个攻击力数值的伤害。那之后，这张卡的攻击力上升给与的伤害一半数值。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_DAMAGE+CATEGORY_ATKCHANGE)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e4:SetTarget(c76075139.thtg)
	e4:SetOperation(c76075139.thop)
	c:RegisterEffect(e4)
end
-- 融合素材过滤条件：属于「群豪」系列。
function c76075139.ffilter(c,fc,sub,mg,sg)
	return c:IsFusionSetCard(0x17d)
end
-- 限制额外卡组里侧表示的这张卡只能通过融合召唤或自身特殊召唤规则来特殊召唤。
function c76075139.splimit(e,se,sp,st)
	local c=e:GetHandler()
	if c:IsLocation(LOCATION_EXTRA) and c:IsFacedown() then return st&SUMMON_TYPE_FUSION==SUMMON_TYPE_FUSION end
	return true
end
-- 自身特殊召唤规则的解放怪兽过滤条件：与额外怪兽区域相同纵列、非融合怪兽、5星以上且属于「群豪」系列。
function c76075139.hspfilter(c,tp,sc)
	local seq=c:GetSequence()
	return (seq==1 or seq==3 or seq>4) and not c:IsFusionType(TYPE_FUSION) and c:IsLevelAbove(5) and c:IsFusionSetCard(0x17d)
		-- 检查怪兽由自己控制、解放该怪兽后额外卡组有可用怪兽区域，且该怪兽能作为特殊召唤素材。
		and c:IsControler(tp) and Duel.GetLocationCountFromEx(tp,tp,c,sc)>0 and c:IsCanBeFusionMaterial(sc,SUMMON_TYPE_SPECIAL)
end
-- 自身特殊召唤规则的条件：这张卡在额外卡组里侧表示，且场上存在满足条件的怪兽可供解放。
function c76075139.hspcon(e,c)
	if c==nil then return true end
	-- 检查这张卡是否里侧表示，且自己场上是否存在至少1只满足条件的怪兽可供解放。
	return c:IsFacedown() and Duel.CheckReleaseGroupEx(c:GetControler(),c76075139.hspfilter,1,REASON_SPSUMMON,false,nil,c:GetControler(),c)
end
-- 自身特殊召唤规则的准备阶段：选择1只满足条件的怪兽作为解放对象并记录。
function c76075139.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己场上可解放的怪兽组，并过滤出满足自身特殊召唤条件的怪兽。
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c76075139.hspfilter,nil,tp,c)
	-- 提示玩家选择要解放的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 自身特殊召唤规则的执行：将选中的怪兽设为素材并解放。
function c76075139.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local tc=e:GetLabelObject()
	c:SetMaterial(Group.FromCards(tc))
	-- 解放选中的怪兽。
	Duel.Release(tc,REASON_SPSUMMON)
end
-- 移动位置效果的怪兽过滤条件：位于主要怪兽区域，且其左侧或右侧的相邻区域为空白。
function c76075139.pfilter(c)
	local seq=c:GetSequence()
	local tp=c:GetControler()
	if seq>4 then return false end
	-- 检查怪兽是否不在最左侧，且其左侧相邻的主要怪兽区域是否可用。
	return (seq>0 and Duel.CheckLocation(tp,LOCATION_MZONE,seq-1))
		-- 或者检查怪兽是否不在最右侧，且其右侧相邻的主要怪兽区域是否可用。
		or (seq<4 and Duel.CheckLocation(tp,LOCATION_MZONE,seq+1))
end
-- 灵摆效果的发动准备：检测是否能特殊召唤或移动怪兽，并让玩家选择其中一个效果发动。
function c76075139.ptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local zone=1<<c:GetSequence()
	local b1=c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
	-- 检查自己场上是否存在可以向相邻区域移动的怪兽。
	local b2=Duel.IsExistingMatchingCard(c76075139.pfilter,tp,LOCATION_MZONE,0,1,nil)
	if chk==0 then return b1 or b2 end
	local s=0
	if b1 and not b2 then
		-- 只能选择特殊召唤效果。
		s=Duel.SelectOption(tp,aux.Stringid(76075139,0))  --"特殊召唤"
	end
	if not b1 and b2 then
		-- 只能选择位置移动效果。
		s=Duel.SelectOption(tp,aux.Stringid(76075139,1))+1  --"位置移动"
	end
	if b1 and b2 then
		-- 让玩家在特殊召唤和位置移动中选择一个效果。
		s=Duel.SelectOption(tp,aux.Stringid(76075139,0),aux.Stringid(76075139,1))  --"特殊召唤/位置移动"
	end
	e:SetLabel(s)
	if s==0 then
		-- 设置特殊召唤的操作信息。
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	end
end
-- 灵摆效果的执行：根据玩家的选择，执行特殊召唤或移动怪兽位置。
function c76075139.pop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local zone=1<<c:GetSequence()
	if e:GetLabel()==0 then
		-- 将这张卡特殊召唤到其正对面的主要怪兽区域。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP,zone)
	end
	if e:GetLabel()==1 then
		-- 提示玩家选择要移动位置的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(76075139,2))  --"请选择移动位置的怪兽"
		-- 让玩家选择1只自己场上满足移动条件的怪兽。
		local sc=Duel.SelectMatchingCard(tp,c76075139.pfilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
		if sc then
			local seq=sc:GetSequence()
			if seq>4 then return end
			local flag=0
			-- 若怪兽不在最左侧且左侧格子可用，则将左侧格子标记加入可选区域。
			if seq>0 and Duel.CheckLocation(tp,LOCATION_MZONE,seq-1) then flag=flag|(1<<(seq-1)) end
			-- 若怪兽不在最右侧且右侧格子可用，则将右侧格子标记加入可选区域。
			if seq<4 and Duel.CheckLocation(tp,LOCATION_MZONE,seq+1) then flag=flag|(1<<(seq+1)) end
			if flag==0 then return end
			-- 提示玩家选择要移动到的位置。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)  --"请选择要移动到的位置"
			-- 让玩家在可选的相邻格子中选择一个。
			local s=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,~flag)
			local nseq=math.log(s,2)
			-- 将选中的怪兽移动到新选择的格子。
			Duel.MoveSequence(sc,nseq)
		end
	end
end
-- 效果①的对象过滤条件：原本是怪兽卡、可以送回手牌且表侧表示存在。
function c76075139.thfilter(c)
	return c:GetOriginalType()&TYPE_MONSTER>0 and c:IsAbleToHand() and c:IsFaceup()
end
-- 效果①的发动准备：选择对方魔陷区1张表侧表示的怪兽卡作为对象，并设置回收和伤害的操作信息。
function c76075139.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(1-tp) and c76075139.thfilter(chkc) end
	-- 检查对方魔法与陷阱区域是否存在至少1张满足条件的怪兽卡。
	if chk==0 then return Duel.IsExistingTarget(c76075139.thfilter,tp,0,LOCATION_SZONE,1,nil) end
	-- 提示玩家选择要返回手牌的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择对方魔法与陷阱区域的1张怪兽卡作为效果对象。
	local g=Duel.SelectTarget(tp,c76075139.thfilter,tp,0,LOCATION_SZONE,1,1,nil)
	-- 设置将目标卡片送回手牌的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	-- 设置给与对方目标怪兽攻击力数值伤害的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,g:GetFirst():GetAttack())
end
-- 效果①的执行：将目标卡片送回手牌，给与对方伤害，并使这张卡的攻击力上升该伤害的一半。
function c76075139.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的目标卡片。
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	-- 检查目标卡片是否仍适用效果，并将其送回持有者手牌。
	if tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_HAND) then
		-- 给与对方该怪兽原本攻击力数值的伤害。
		local dam=Duel.Damage(1-tp,tc:GetAttack(),REASON_EFFECT)
		if dam>0 and c:IsRelateToEffect(e) and c:IsFaceup() then
			-- 中断效果处理，使后续的攻击力上升处理不与伤害同时发生。
			Duel.BreakEffect()
			-- 那之后，这张卡的攻击力上升给与的伤害一半数值。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(math.floor(dam/2))
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
			c:RegisterEffect(e1)
		end
	end
end
