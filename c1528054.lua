--影法師トップハットヘア
-- 效果：
-- 效果怪兽2只
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡连接召唤的场合才能发动。把持有把自身作为怪兽特殊召唤效果的1张永续陷阱卡从卡组到自己场上盖放。这张卡在这个回合不能作为连接素材。
-- ②：这张卡和怪兽进行战斗的场合，那2只不会被那次战斗破坏。
-- ③：魔法与陷阱区域的卡在怪兽区域特殊召唤的场合，以对方场上1张魔法·陷阱卡为对象才能发动。那张卡破坏。
local s,id,o=GetID()
-- 初始化效果登记：给此卡添加“2只效果怪兽”的连接召唤手续并允许苏生限制，随后注册①的盖放永续陷阱诱发效果、②的战斗破坏免疫永续效果、③的破坏对方魔陷诱发效果。
function s.initial_effect(c)
	-- 设置连接召唤手续：此卡必须用2只效果怪兽作为连接素材才能连接召唤。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,TYPE_EFFECT),2)
	c:EnableReviveLimit()
	-- 这个卡名的①③的效果1回合各能使用1次。①：这张卡连接召唤的场合才能发动。把持有把自身作为怪兽特殊召唤效果的1张永续陷阱卡从卡组到自己场上盖放。这张卡在这个回合不能作为连接素材。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"盖放永续陷阱卡"
	e1:SetCategory(CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.setcon)
	e1:SetTarget(s.settg)
	e1:SetOperation(s.setop)
	c:RegisterEffect(e1)
	-- ②：这张卡和怪兽进行战斗的场合，那2只不会被那次战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(s.indtg)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- 这个卡名的①③的效果1回合各能使用1次。③：魔法与陷阱区域的卡在怪兽区域特殊召唤的场合，以对方场上1张魔法·陷阱卡为对象才能发动。那张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"破坏魔法·陷阱卡"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.descon)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
end
-- ①效果的发动条件：只有这张卡以连接召唤方式成功特殊召唤的场合才能发动。
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- ①效果的检索过滤条件：选择卡组中1张可以盖放的永续陷阱卡，且其持有等级/种族/属性/攻击力/守备力中至少一项，代表它具备“把自身作为怪兽特殊召唤”的效果。
function s.filter(c)
	return c:IsType(TYPE_TRAP) and c:IsType(TYPE_CONTINUOUS) and c:IsSSetable()
		and (c:GetOriginalLevel()>0
		or bit.band(c:GetOriginalRace(),0x3fffffff)~=0
		or bit.band(c:GetOriginalAttribute(),0x7f)~=0
		or c:GetBaseAttack()>0
		or c:GetBaseDefense()>0)
end
-- ①效果的发动合法判定：自己魔陷区有空位，并且卡组中存在符合条件的永续陷阱卡时才能发动。
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己魔陷区是否有可用的空格用于盖放。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查卡组中是否存在至少1张满足s.filter过滤条件的永续陷阱卡。
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
end
-- ①效果处理：玩家从卡组选择1张符合条件的永续陷阱卡盖放到自己魔陷区；随后若这张卡仍与效果关联，给它附加“这个回合不能作为连接素材”的永续效果。
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 处理时再次确认自己魔陷区仍有空格，只有有空格才执行盖放。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		-- 给操作玩家显示“请选择要盖放的卡”的选择提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
		-- 从自己卡组中选出1张满足s.filter的永续陷阱卡（让玩家选择）。
		local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
		local tc=g:GetFirst()
		if tc then
			-- 将选中的卡以里侧表示盖放到自己的魔法与陷阱区域。
			Duel.SSet(tp,tc)
		end
	end
	if c:IsRelateToEffect(e) then
		-- ①：这张卡连接召唤的场合才能发动。把持有把自身作为怪兽特殊召唤效果的1张永续陷阱卡从卡组到自己场上盖放。这张卡在这个回合不能作为连接素材。②：这张卡和怪兽进行战斗的场合，那2只不会被那次战斗破坏。③：魔法与陷阱区域的卡在怪兽区域特殊召唤的场合，以对方场上1张魔法·陷阱卡为对象才能发动。那张卡破坏。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1,true)
	end
end
-- ②效果的战斗破坏免疫对象判定：当场上怪兽进行战斗时，若该怪兽是这张卡自身或这张卡的战斗对象，则赋予其战斗破坏免疫。
function s.indtg(e,c)
	local tc=e:GetHandler()
	return c==tc or c==tc:GetBattleTarget()
end
-- 用于③效果的条件过滤：判断一张卡是否在特殊召唤之前位于魔法与陷阱区域（即从魔陷区被特殊召唤到怪兽区）。
function s.cfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_SZONE)
end
-- ③效果的发动条件：本次特殊召唤成功的怪兽群中不包含此卡自身，且其中至少有一只卡是从魔法与陷阱区域特殊召唤到怪兽区的。
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return not eg:IsContains(c) and eg:IsExists(s.cfilter,1,nil)
end
-- ③效果对象过滤：选择场上存在的魔法·陷阱卡（作为破坏对象）。
function s.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- ③效果的目标指定：选择对方场上1张魔法·陷阱卡为对象，并设置破坏信息；若检查对象则需满足是对方场上且是魔陷。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and s.desfilter(chkc) and chkc:IsControler(1-tp) end
	-- ③效果发动时检查是否存在至少1张符合条件的对方场上的魔法·陷阱卡可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(s.desfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 给操作玩家显示“请选择要破坏的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从对方场上选择1张魔法·陷阱卡作为对象（同时将该卡登记为当前连锁的效果对象）。
	local g=Duel.SelectTarget(tp,s.desfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设定本次连锁处理信息：将破坏1张卡的分类设为CATEGORY_DESTROY，并记录对象卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ③效果处理：取得连锁对象，若对象仍与效果关联，将其破坏。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动③效果时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因将对象卡破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
