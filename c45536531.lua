--ファニー・ダーク・ラビット
local s,id,o=GetID()
-- 注册召唤·特殊召唤成功时增加通常召唤机会、在场上有卡通世界存在时追加卡通属性、以及起动效果检索或放置卡通场地或永续魔陷的3个效果
function s.initial_effect(c)
	-- 在系统卡片信息中注册本卡关联的卡片密码「卡通世界」
	aux.AddCodeList(c,15259703)
	-- ①：这张卡召唤·特殊召唤成功的场合发动。这个回合，自己在通常召唤外加上只有1次，自己主要阶段可以把有「卡通世界」卡名记述的1只怪兽召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetOperation(s.sumop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：只要场上有「卡通世界」存在，这张卡当作卡通怪兽使用
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_ADD_TYPE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.addcon)
	e3:SetValue(TYPE_TOON)
	c:RegisterEffect(e3)
	-- ③：1回合1次，自己主要阶段才能发动。从卡组把1张「卡通」场地魔法卡或「卡通」永续魔法卡加入手手卡或在自己场上表侧表示放置
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetCountLimit(1)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)
end
-- 过滤条件：有「卡通世界」卡名记述的怪兽
function s.sumfilter(e,c)
	-- 检查卡片是否记述有「卡通世界」
	return aux.IsCodeListed(c,15259703)
end
-- 效果①的Operation函数：注册可在通常召唤外追加1次有「卡通世界」记述的怪兽的召唤权的场上效果，并标记此卡的效果已被本回合使用
function s.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查本回合玩家是否已经通过此卡的效果获得过召唤权，若是则不再重复适用
	if Duel.GetFlagEffect(tp,id)~=0 then return end
	-- 向双方玩家展示该发动效果的卡片
	Duel.Hint(HINT_CARD,0,id)
	-- 这个回合，自己在通常召唤外加上只有1次，自己主要阶段可以把有「卡通世界」卡名记述的1只怪兽召唤
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e1:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTarget(s.sumfilter)
	-- 注册增加召唤次数的场上效果
	Duel.RegisterEffect(e1,tp)
	-- 标记玩家本回合已适用过此卡的召唤机会追加效果
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
end
-- 过滤条件：在场上表侧表示存在的「卡通世界」
function s.cfilter(c)
	return c:IsFaceup() and c:IsCode(15259703)
end
-- 效果②的Condition条件函数：检查场上是否存在「卡通世界」
function s.addcon(e)
	-- 检查双方场上是否存在表侧表示的「卡通世界」
	return Duel.IsExistingMatchingCard(s.cfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end
-- 过滤条件：卡组中是「卡通」字段的场地魔法或永续魔法，且可以加入手牌，或者在不被限制放置且满足魔陷格子/场地限制的条件下在自己场上放置
function s.thfilter(c,tp)
	if not (c:IsSetCard(0x62) and c:IsType(TYPE_SPELL) and c:IsType(TYPE_FIELD+TYPE_CONTINUOUS)) then return false end
	return c:IsAbleToHand() or not c:IsForbidden() and c:CheckUniqueOnField(tp)
		-- 且该卡是场地魔法，或者自己场上的魔法与陷阱区域有空位
		and (c:IsType(TYPE_FIELD) or Duel.GetLocationCount(tp,LOCATION_SZONE)>0)
end
-- 效果③的Target函数：检查卡组是否存在可回收或放置的「卡通」场地或永续魔法卡
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足过滤条件的「卡通」场地或永续魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,tp) end
end
-- 效果③的Operation函数：从卡组检索1张满足条件的卡，根据卡片状态及玩家选择，将其加入手牌或直接表侧放置在场上
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要操作的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 从卡组中选择1张满足条件的「卡通」场地或永续魔法卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,tp)
	local tc=g:GetFirst()
	if tc then
		-- 检查所选卡片是否可以无限制地在场上表侧放置（包括魔陷区/场地格检查）
		local pchk=not tc:IsForbidden() and tc:CheckUniqueOnField(tp) and (tc:IsType(TYPE_FIELD) or Duel.GetLocationCount(tp,LOCATION_SZONE)>0)
		-- 若该卡能加入手牌，且无法放置在场上，或者玩家主动选择加入手牌的分支
		if tc:IsAbleToHand() and (not pchk or Duel.SelectOption(tp,1190,aux.Stringid(id,3))==0) then
			-- 将所选卡片加入手牌
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 给对方玩家确认所加入手牌的卡片
			Duel.ConfirmCards(1-tp,tc)
		elseif pchk then
			if tc then
				if tc:IsType(TYPE_CONTINUOUS) then
					-- 若为永续魔法卡，将其表侧表示放置在魔法与陷阱区域
					Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
				else
					-- 若为场地魔法卡，将其表侧表示放置在场地区域
					Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
				end
			end
		end
	end
end
